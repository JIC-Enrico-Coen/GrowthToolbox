function [guiObject,tag,fig,handles,panelfig,panelhandles] = getGFtboxFigFromGuiObject( guiObject )
%[clickedItem,tag,fig,handles] = getGFtboxFigFromGuiObject()
%   This can be called at the start of a callback procedure for an item in
%   a floating panel.  It finds the main GFtbox window and, if required,
%   its handles structure.  It also returns the handle of the item clicked
%   on and its tag.
%
%   It can also be used at the beginning of a
%   callback that is called from a widget in the main GFtbox window.  It
%   mostly isn't, because those callbacks were mostly written before
%   floating subpanels were implemented.
%
%   Outputs:
%   clickItem: a handle to the item clicked on.
%   tag: the tag of the item clicked on.
%   fig: the GFtbox main window.
%   handles: the guidata of the GFtbox main window, containing handles to
%       the mesh and all of the GUI widgets.
%   panelfig: the figure containing the clicked item. This may or may not
%       be the same as the GFtbox main window.
%   handles: the guidata of panelfig, containing handles to
%       all of the GUI widgets that it contains.

    if nargin < 1
        guiObject = gcbo();
    end
    tag = '';
    fig = [];
    handles = [];
    panelfig = [];
    panelhandles = [];
    if isempty(guiObject)
        return;
    end
    tag = get( guiObject, 'Tag' );
    panelfig = ancestor( guiObject, 'figure' );
    if isempty(panelfig)
        return;
    end
    if strcmp( get( panelfig,'Tag'), 'GFTwindow' )
        fig = panelfig;
    else
        ud = get( panelfig, 'userdata' );
        if isfield( ud, 'GFtboxHandle' )
            fig = ud.GFtboxHandle;
        end
    end
    if ~isempty(fig) && (nargout >= 4)
        handles = guidata(fig);
    end
    if ~isempty(panelfig) && (nargout >= 6)
        panelhandles = guidata(panelfig);
    end
end
