unit in0k_lazIdeSRC_srcTree_FNK_absPATH_FND;

{$mode objfpc}{$H+}

interface

uses
  in0k_lazIdeSRC_srcTree_CORE_item,
  in0k_lazIdeSRC_srcTree_CORE_itemFileSystem,
  in0k_lazIdeSRC_srcTree_item_Globals,
  in0k_lazIdeSRC_srcTree_item_fsFolder,
  //---
  in0k_lazIdeSRC_srcTree_CORE_fileSystem_FNK,
  in0k_lazIdeSRC_srcTree_FNK_relPATH_FND;

function SrcTree_fndAbsPATH(const item:tSrcTree_ROOT; const folder:string):_tSrcTree_item_fsNodeFLDR_;

implementation

function SrcTree_fndAbsPATH(const item:tSrcTree_ROOT; const folder:string):_tSrcTree_item_fsNodeFLDR_;
var tmp:tSrcTree_item;
begin
    result:=nil;
    //---
    tmp:=item.ItemCHLD;
    while Assigned(tmp) do begin
        if tmp is _tSrcTree_item_fsNodeFLDR_ then begin
            if srcTree_fsFnk_FileIsInPath(folder,_tSrcTree_item_fsNodeFLDR_(tmp).src_abs_PATH)
            then BREAK;
        end;
        tmp:=tmp.ItemNEXT;
    end;
    //---
    if Assigned(tmp) then begin
        result:=SrcTree_fndRelPATH(_tSrcTree_item_fsNodeFLDR_(tmp), srcTree_fsFnk_CreateRelativePath(folder,_tSrcTree_item_fsNodeFLDR_(tmp).src_abs_PATH));
    end;
end;

end.
