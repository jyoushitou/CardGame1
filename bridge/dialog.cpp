#include "bridge_common.h"

__declspec(dllexport) char* bridge_show_open_dialog(HWND hwnd, const char* title,
    const char* filter, bool multiSelect) {
    CoInitializeEx(NULL, COINIT_APARTMENTTHREADED);
    IFileOpenDialog* dlg = NULL;
    if (FAILED(CoCreateInstance(CLSID_FileOpenDialog, NULL, CLSCTX_ALL,
        IID_IFileOpenDialog, (void**)&dlg))) {
        char* empty = (char*)malloc(1); empty[0] = '\0'; return empty;
    }

    wchar_t* wtitle = title ? utf8_to_utf16(title) : NULL;
    if (wtitle) { dlg->SetTitle(wtitle); free(wtitle); }

    wchar_t* wf = build_filter(filter);
    if (wf) {
        COMDLG_FILTERSPEC fs;
        fs.pszName = L"Files"; fs.pszSpec = wf;
        dlg->SetFileTypes(1, &fs);
    }

    DWORD flags; dlg->GetOptions(&flags);
    flags |= FOS_FORCEFILESYSTEM;
    if (multiSelect) flags |= FOS_ALLOWMULTISELECT;
    dlg->SetOptions(flags);

    char* result = NULL;
    if (SUCCEEDED(dlg->Show(hwnd))) {
        IShellItem* item;
        if (SUCCEEDED(dlg->GetResult(&item))) {
            wchar_t* wpath;
            if (SUCCEEDED(item->GetDisplayName(SIGDN_FILESYSPATH, &wpath))) {
                result = utf16_to_utf8(wpath);
                CoTaskMemFree(wpath);
            }
            item->Release();
        }
    }
    dlg->Release();
    if (wf) free(wf);
    if (!result) { result = (char*)malloc(1); result[0] = '\0'; }
    return result;
}

__declspec(dllexport) char* bridge_show_save_dialog(HWND hwnd, const char* title,
    const char* filter, const char* defaultName) {
    CoInitializeEx(NULL, COINIT_APARTMENTTHREADED);
    IFileSaveDialog* dlg = NULL;
    if (FAILED(CoCreateInstance(CLSID_FileSaveDialog, NULL, CLSCTX_ALL,
        IID_IFileSaveDialog, (void**)&dlg))) {
        char* empty = (char*)malloc(1); empty[0] = '\0'; return empty;
    }

    wchar_t* wtitle = title ? utf8_to_utf16(title) : NULL;
    if (wtitle) { dlg->SetTitle(wtitle); free(wtitle); }

    wchar_t* wf = build_filter(filter);
    if (wf) {
        COMDLG_FILTERSPEC fs;
        fs.pszName = L"Files"; fs.pszSpec = wf;
        dlg->SetFileTypes(1, &fs);
    }

    if (defaultName) {
        wchar_t* wdn = utf8_to_utf16(defaultName);
        if (wdn) { dlg->SetFileName(wdn); free(wdn); }
    }

    DWORD flags; dlg->GetOptions(&flags);
    flags |= FOS_FORCEFILESYSTEM;
    dlg->SetOptions(flags);

    char* result = NULL;
    if (SUCCEEDED(dlg->Show(hwnd))) {
        IShellItem* item;
        if (SUCCEEDED(dlg->GetResult(&item))) {
            wchar_t* wpath;
            if (SUCCEEDED(item->GetDisplayName(SIGDN_FILESYSPATH, &wpath))) {
                result = utf16_to_utf8(wpath);
                CoTaskMemFree(wpath);
            }
            item->Release();
        }
    }
    dlg->Release();
    if (wf) free(wf);
    if (!result) { result = (char*)malloc(1); result[0] = '\0'; }
    return result;
}

__declspec(dllexport) void bridge_free_string(void* str) {
    if (str) free(str);
}
