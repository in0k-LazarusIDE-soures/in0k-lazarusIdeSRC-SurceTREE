unit in0k_lazIdeSRC_srcTree_CORE_item;

{$mode objfpc}{$H+}

interface

{$i in0k_lazIdeSRC_SETTINGs.inc} //< настройки компанента-Расширения.
//< Можно смело убирать, так как будеть работать только в моей специальной
//< "системе имен и папок" `in0k_LazExt_..`.

{$ifDef in0k_lazIdeSRC_srcTree___DEBUG}uses in0k_lazIdeSRC_DEBUG;{$endIf}

type

 tSrcTree_item=class
  protected
   _prnt_:tSrcTree_item;
   _next_:tSrcTree_item;
   _chld_:tSrcTree_item;
  protected
    function  _clc_countSONs_  :integer;
    function  _clc_conntCHILDs_:integer;
  protected
    function  _get_chldFrst_:tSrcTree_item;
    function  _get_chldLast_:tSrcTree_item;
  protected
    procedure _ins_itemAfte_(const node:tSrcTree_item);
    procedure _ins_ChldFrst_(const node:tSrcTree_item);
    procedure _ins_ChldLast_(const node:tSrcTree_item);
  protected
   _item_Text_:string;
    function _get_itemText_:string; inline;
    function _get_ItemName_:string; virtual;
    function _get_ItemHint_:string; virtual;
  public //< навигация
    property ItemPRNT:tSrcTree_item read _prnt_;
    property ItemNEXT:tSrcTree_item read _next_;
    property ItemCHLD:tSrcTree_item read _chld_;
  public //< текстовки
    property ItemTEXT:string read _get_itemText_; // что вложили при создании
    property ItemNAME:string read _get_ItemName_; // название
    property ItemHINT:string read _get_ItemHint_; // описание
  public
    property CountSONs  :integer read _clc_countSONs_;
    property CountCHILDs:integer read _clc_conntCHILDs_;
  public
    procedure CopyData(const source:tSrcTree_item); virtual;
  public
    constructor Create;                    virtual;
    constructor Create(const Text:string); virtual;
    destructor DESTROY; override;
  end;

 _tSrcTree_ROOT_=class(tSrcTree_item);

function  SrcTree_isParent_4_Item(const prnt,item:tSrcTree_item):boolean;

//<-----------------------------------------------------------------------------
procedure SrcTree_re_set_itemTEXT(const item:tSrcTree_item; const newItemTXT:string);
procedure SrcTree_insert_itemAfte(const item:tSrcTree_item; const insertItem:tSrcTree_item);
procedure SrcTree_insert_ChldFrst(const item:tSrcTree_item; const insertItem:tSrcTree_item);
procedure SrcTree_insert_ChldLast(const item:tSrcTree_item; const insertItem:tSrcTree_item);
procedure SrcTree_cut_From_Parent(const item:tSrcTree_item);
procedure SrcTree_Copy_items_Text(const source,target:tSrcTree_item);

implementation
{%region --- возня с ДЕБАГОМ -------------------------------------- /fold}
{$if declared(in0k_lazIde_DEBUG)}
    // `in0k_lazIde_DEBUG` - это функция ИНДИКАТОР что используется
    //                       моя "система имен и папок"
    {$define _debug_}     //< типа да ... можно делать ДЕБАГ отметки
{$else}
    {$undef _debug_}
{$endIf}
{%endregion}

constructor tSrcTree_item.Create;
begin
   _item_Text_:='';
   _prnt_:=nil;
   _next_:=nil;
   _chld_:=nil;
end;

constructor tSrcTree_item.Create(const Text:string);
begin
    Create;
   _item_Text_:=Text;
end;

destructor tSrcTree_item.DESTROY;
var tmp:tSrcTree_item;
begin
    // чистим ДЕТЕЙ
    tmp:=ItemCHLD;
    while Assigned(tmp) do begin
        SrcTree_cut_From_Parent(tmp);
        tmp.FREE;
        //--->
        tmp:=ItemCHLD;
    end;
    // чистим СЕБЯ
   _item_Text_:=''; //< наследие мифов
   _prnt_    :=nil;
   _next_    :=nil;
   _chld_    :=nil;
end;

//------------------------------------------------------------------------------

procedure tSrcTree_item.CopyData(const source:tSrcTree_item);
begin
    self._item_Text_:=source._item_Text_;
end;

//------------------------------------------------------------------------------

function tSrcTree_item._get_chldFrst_:tSrcTree_item;
begin
    result:=_chld_;
end;

function tSrcTree_item._get_chldLast_:tSrcTree_item;
begin
    result:=_chld_;
    while Assigned(result) do begin
        if not Assigned(result._next_) then break;
        result:=result._next_;
    end;
end;

//------------------------------------------------------------------------------

// сичтаем ПРЯМЫХ сыновей
function tSrcTree_item._clc_countSONs_:integer;
var tmp:tSrcTree_item;
begin
    result:=0;
    tmp:=self._chld_;
    while Assigned(tmp) do begin
        result:=result+1;
        //-->
        tmp:=tmp._next_;
    end;
end;

// сичтаем ВСЕХ потомков
function tSrcTree_item._clc_conntCHILDs_:integer;
var tmp:tSrcTree_item;
begin {todo: уйти от рекурсии}
    result:=0;
    tmp:=self._chld_;
    while Assigned(tmp) do begin
        result:=result+1+tmp._clc_conntCHILDs_;
        //-->
        tmp:=tmp._next_;
    end;
end;

//------------------------------------------------------------------------------

procedure tSrcTree_item._ins_itemAfte_(const node:tSrcTree_item);
begin
    {$IfOpt D+}Assert(Assigned(node));{$endIf}
    node._prnt_:=self._prnt_;
    node._next_:=self._next_;
    self._next_:=node;

end;

procedure tSrcTree_item._ins_ChldFrst_(const node:tSrcTree_item);
begin
    {$IfOpt D+}Assert(Assigned(node));{$endIf}
    node._prnt_:=self;
    node._next_:=self._chld_;
    self._chld_:=node;
end;

procedure tSrcTree_item._ins_ChldLast_(const node:tSrcTree_item);
var tmp:tSrcTree_item;
begin
    {$IfOpt D+}Assert(Assigned(node));{$endIf}
    tmp:=_get_chldLast_;
    if Assigned(tmp) then tmp._ins_itemAfte_(node)
    else self._ins_ChldFrst_(node);
end;

//------------------------------------------------------------------------------

function tSrcTree_item._get_ItemText_:string;
begin
    result:=_item_Text_;
end;

function tSrcTree_item._get_ItemName_:string;
begin
    result:=_get_ItemText_;
end;

function tSrcTree_item._get_ItemHint_:string;
begin
    result:='';
end;

//==============================================================================

function  SrcTree_isParent_4_Item(const prnt,item:tSrcTree_item):boolean;
var tmp:tSrcTree_item;
begin
    {$IfOpt D+}
        Assert(Assigned(prnt));
        Assert(Assigned(item));
    {$endIf}
    result:=false;
    tmp:=item.ItemPRNT;
    while Assigned(tmp) do begin
        if tmp=prnt then begin
            result:=true;
            BREAK;
        end;
        tmp:=tmp.ItemPRNT;
    end;
end;

//------------------------------------------------------------------------------

procedure SrcTree_insert_itemAfte(const item:tSrcTree_item; const insertItem:tSrcTree_item);
begin
    {$IfOpt D+}
        Assert(Assigned(item));
        Assert(Assigned(insertItem));
    {$endIf}
    item._ins_itemAfte_(insertItem);
end;

procedure SrcTree_insert_ChldFrst(const item:tSrcTree_item; const insertItem:tSrcTree_item);
begin
    {$IfOpt D+}
        Assert(Assigned(item));
        Assert(Assigned(insertItem));
    {$endIf}
    item._ins_ChldFrst_(insertItem);
end;

procedure SrcTree_insert_ChldLast(const item:tSrcTree_item; const insertItem:tSrcTree_item);
begin
    {$IfOpt D+}
        Assert(Assigned(item));
        Assert(Assigned(insertItem));
    {$endIf}
    item._ins_ChldLast_(insertItem);
end;

procedure SrcTree_cut_From_Parent(const item:tSrcTree_item);
var tmp:pointer;
begin
    {$IfOpt D+}
        Assert(Assigned(item));
        Assert(Assigned(item.ItemPRNT));
    {$endIf}
    tmp:=@(item.ItemPRNT._chld_);
    while (tSrcTree_item(tmp^)<>item)
    do tmp:=@(tSrcTree_item(tmp^)._next_);
    tSrcTree_item(tmp^):=item.ItemNEXT;
    item._next_:=nil;
end;

//------------------------------------------------------------------------------

// ПЕРЕУСТАНоВИТЬ, значение _item_Text_ ??? почему так, вопрос ^-)
procedure SrcTree_re_set_itemTEXT(const item:tSrcTree_item; const newItemTXT:string);
begin
    {$IfOpt D+}Assert(Assigned(item));{$endIf}
    {$ifdef _debug_}DEBUG('SrcTree_re_set_itemTEXT','"'+item._item_Text_+'"'+'->'+'"'+newItemTXT+'"');{$endIf}
    item._item_Text_:=newItemTXT;
end;

procedure SrcTree_Copy_items_Text(const source,target:tSrcTree_item); deprecated 'use target.CopyData(source)';
begin
    {$IfOpt D+}Assert(Assigned(source));{$endIf}
    {$IfOpt D+}Assert(Assigned(target));{$endIf}
    target._item_Text_:=source._item_Text_;
end;

end.

