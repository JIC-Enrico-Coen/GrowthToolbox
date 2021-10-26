function makefig(ProjectFullPath)
    if nargin < 1
        ProjectFullPath = '';
    end
    [FileName,PathName,~] = uigetfile(fullfile(ProjectFullPath,'*.mat'),'Choose a stage file');
    if isnumeric(FileName) && (FileName==0)
        return;
    end
    M=load(fullfile(PathName,FileName));
    if isfield( M, m )
        m = M.m;
    else
        m = M;
    end
    m = upgrademesh(m);
    m=leaf_plot(m);
    h = guidata( m.pictures(1) );
    c=h.picture;
    axes(c);
    cc=get(c,'Children');
    ccc=findobj(cc,'type','patch');
    set(ccc,'DiffuseStrength',0.5,...
        'AmbientStrength',0.8,...
        'FaceLighting','phong',...%'gouraud',...
        'Backfacelighting','reverselit');
    cameratoolbar(ancestor(m.pictures(1),'figure'));
    p=ccc(1);
    a=get(p,'parent');
    set(a,'Zgrid','off','Xgrid','off','Ygrid','off');
end