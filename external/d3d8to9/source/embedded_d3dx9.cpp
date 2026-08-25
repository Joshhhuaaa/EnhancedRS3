/**
 * Embedded D3DX9 loader.
 */

#include "d3dx9.hpp"
#include "embedded_d3dx9.hpp"

#include <d3dcompiler.h>

extern "C" {
#include "MemoryModule/MemoryModule.h"
}

// The two Microsoft redistributable DLLs, baked in as byte arrays.
//   d3dx9_data_43.h        -> const BYTE D3DX9_43[]
//   d3dcompiler_data_47.h  -> const BYTE D3DCompiler_47[]
#include "d3dx9_data_43.h"
#include "d3dcompiler_data_47.h"

// Own typedefs so we don't depend on the SDK exporting pD3DAssemble.
typedef HRESULT(WINAPI *PFN_D3DAssemble)(LPCVOID pSrcData, SIZE_T SrcDataSize, LPCSTR pSourceName,
	const D3D_SHADER_MACRO *pDefines, ID3DInclude *pInclude, UINT Flags,
	ID3DBlob **ppCode, ID3DBlob **ppErrorMsgs);
typedef HRESULT(WINAPI *PFN_D3DCompile)(LPCVOID pSrcData, SIZE_T SrcDataSize, LPCSTR pSourceName,
	const D3D_SHADER_MACRO *pDefines, ID3DInclude *pInclude, LPCSTR pEntrypoint, LPCSTR pTarget,
	UINT Flags1, UINT Flags2, ID3DBlob **ppCode, ID3DBlob **ppErrorMsgs);
typedef HRESULT(WINAPI *PFN_D3DDisassemble)(LPCVOID pSrcData, SIZE_T SrcDataSize, UINT Flags,
	LPCSTR szComments, ID3DBlob **ppDisassembly);

static HMEMORYMODULE  g_d3dx9Module = nullptr;
static HMEMORYMODULE  g_d3dCompilerModule = nullptr;

static PFN_D3DAssemble    p_D3DAssemble = nullptr;
static PFN_D3DCompile     p_D3DCompile = nullptr;
static PFN_D3DDisassemble p_D3DDisassemble = nullptr;

// ID3DXBuffer and ID3DBlob use the same COM interface layout, and D3DXMACRO
// matches D3D_SHADER_MACRO field-for-field, so the reinterpret_casts are safe.

static HRESULT WINAPI Emb_D3DXAssembleShader(LPCSTR pSrcData, UINT SrcDataLen, const D3DXMACRO *pDefines,
	LPD3DXINCLUDE pInclude, DWORD Flags, LPD3DXBUFFER *ppShader, LPD3DXBUFFER *ppErrorMsgs)
{
	if (p_D3DAssemble == nullptr)
		return E_FAIL;

	return p_D3DAssemble(pSrcData, SrcDataLen, nullptr,
		reinterpret_cast<const D3D_SHADER_MACRO *>(pDefines),
		reinterpret_cast<ID3DInclude *>(pInclude), Flags,
		reinterpret_cast<ID3DBlob **>(ppShader),
		reinterpret_cast<ID3DBlob **>(ppErrorMsgs));
}

static HRESULT WINAPI Emb_D3DXCompileShader(LPCSTR pSrcData, UINT SrcDataLen, const D3DXMACRO *pDefines,
	LPD3DXINCLUDE pInclude, LPCSTR pFunctionName, LPCSTR pProfile, DWORD Flags,
	LPD3DXBUFFER *ppShader, LPD3DXBUFFER *ppErrorMsgs, LPD3DXCONSTANTTABLE *ppConstantTable)
{
	// D3DCompile produces no D3DX constant table. Every call site passes nullptr here, so
	// null it out defensively for any that later doesn't.
	if (ppConstantTable != nullptr)
		*ppConstantTable = nullptr;

	if (p_D3DCompile == nullptr)
		return E_FAIL;

	return p_D3DCompile(pSrcData, SrcDataLen, nullptr,
		reinterpret_cast<const D3D_SHADER_MACRO *>(pDefines),
		reinterpret_cast<ID3DInclude *>(pInclude),
		pFunctionName, pProfile, Flags, 0,
		reinterpret_cast<ID3DBlob **>(ppShader),
		reinterpret_cast<ID3DBlob **>(ppErrorMsgs));
}

static HRESULT WINAPI Emb_D3DXDisassembleShader(const DWORD *pShader, BOOL EnableColorCode,
	LPCSTR pComments, LPD3DXBUFFER *ppDisassembly)
{
	if (p_D3DDisassemble == nullptr || pShader == nullptr)
		return D3DERR_INVALIDCALL;

	// D3DDisassemble needs a byte length; a D3D8/9 shader token stream ends with
	// the END token 0x0000FFFF. Validate the version header, then scan for it.
	const BYTE *const Bytes = reinterpret_cast<const BYTE *>(pShader);
	if (!(Bytes[0] <= 0x04 &&                                   // minor version
		  Bytes[1] <= 0x02 &&                                   // major version
		  (Bytes[2] == 0xFF || Bytes[2] == 0xFE) &&             // 0xFF ps_x_x, 0xFE vs_x_x
		  Bytes[3] == 0xFF))
		return D3DERR_INVALIDCALL;

	SIZE_T Size = 4;
	while (true)
	{
		if (Bytes[Size + 0] == 0xFF && Bytes[Size + 1] == 0xFF &&
			Bytes[Size + 2] == 0x00 && Bytes[Size + 3] == 0x00)
		{
			Size += 4;
			break;
		}
		if (++Size > 50000)   // runaway guard
			return E_OUTOFMEMORY;
	}

	const UINT DisasmFlags = EnableColorCode ? D3D_DISASM_ENABLE_COLOR_CODE : 0;
	return p_D3DDisassemble(pShader, Size, DisasmFlags, pComments,
		reinterpret_cast<ID3DBlob **>(ppDisassembly));
}

bool InitEmbeddedD3DX()
{
	static bool Done = false;
	static bool Ok = false;
	if (Done)
		return Ok;
	Done = true;

	g_d3dCompilerModule = MemoryLoadLibrary(D3DCompiler_47, sizeof(D3DCompiler_47));
	g_d3dx9Module = MemoryLoadLibrary(D3DX9_43, sizeof(D3DX9_43));

	if (g_d3dCompilerModule != nullptr)
	{
		p_D3DAssemble = reinterpret_cast<PFN_D3DAssemble>(MemoryGetProcAddress(g_d3dCompilerModule, "D3DAssemble"));
		p_D3DCompile = reinterpret_cast<PFN_D3DCompile>(MemoryGetProcAddress(g_d3dCompilerModule, "D3DCompile"));
		p_D3DDisassemble = reinterpret_cast<PFN_D3DDisassemble>(MemoryGetProcAddress(g_d3dCompilerModule, "D3DDisassemble"));
	}

	if (p_D3DAssemble != nullptr)
		D3DXAssembleShader = &Emb_D3DXAssembleShader;
	// d3dx9_43's own HLSL path hands off to a d3dcompiler_43.dll that is not embedded here,
	// so the compiler comes from d3dcompiler_47 like the assembler does
	if (p_D3DCompile != nullptr)
		D3DXCompileShader = &Emb_D3DXCompileShader;
	if (p_D3DDisassemble != nullptr)
		D3DXDisassembleShader = &Emb_D3DXDisassembleShader;

	// Self-contained exports, resolved straight out of the embedded d3dx9_43
	if (g_d3dx9Module != nullptr)
	{
		D3DXLoadSurfaceFromSurface = reinterpret_cast<PFN_D3DXLoadSurfaceFromSurface>(
			MemoryGetProcAddress(g_d3dx9Module, "D3DXLoadSurfaceFromSurface"));
		D3DXCreateTextureFromFileInMemoryEx = reinterpret_cast<PFN_D3DXCreateTextureFromFileInMemoryEx>(
			MemoryGetProcAddress(g_d3dx9Module, "D3DXCreateTextureFromFileInMemoryEx"));
	}

	// All required shader functions are available.
	Ok = (D3DXAssembleShader != nullptr &&
	      D3DXDisassembleShader != nullptr &&
	      D3DXLoadSurfaceFromSurface != nullptr);
	return Ok;
}
