function m=MorphogenViewer(m,option)
    % J.Andrew Bangham CMP, UEA, 2008.
    global MorphogenViewer_h
    if nargin<1
        disp(sprintf('First argument is the mesh.'));
        disp(sprintf('Export the mesh from GFtbox:Wizard then type'));
        disp(sprintf('global EXTERNMESH'));
        disp(sprintf('MorphogenViewer(EXTERNMESH);'));
    end
    if isstruct(m)
        % Open, move, and get the handles from the figure file.
        fig = openfig(mfilename, 'reuse');
        % Move the gui and then show it, rather than have it jump all over the
        % place.
        movegui(fig, 'southwest');
        set(fig, 'visible', 'on');
        handles = guihandles(fig);
        ListOfMorphogens=fieldnames(m.mgenNameToIndex);
        handles = setupcallbacks(handles,ListOfMorphogens);

        % Initialize the application data structure
        ad.figMain = fig;
        ad.handles = handles;
        ad.m = m;
        ad.imorph=1;
        ad.morph=ListOfMorphogens{1};
        ad.alpha=0;
        ad=setupAxes(ad);
        guidata(ad.figMain,ad);
        MorphogenViewer_h=fig;
    else
        ad=guidata(MorphogenViewer_h);
        switch m
            case 'doSelectMorphogen'
                ad=doSelectMorphogen(ad,option);
            case 'doMachineDrawn'
                ad=doMachineDrawn(ad,option);
            case 'doClip'
                ad=update(ad,ad.morph);
            case 'doFEEdges'
                ad=update(ad,ad.morph);
            case 'doColour'
                ad=doColour(ad,option);
            case 'doHatch'
                ad=doHatch(ad,option);
            case 'doFix'
                ad=doFix(ad,option);
            case 'Print'
                ad=Print(ad,option);
            otherwise
                error('GUI error, command not recognised')
        end
        guidata(MorphogenViewer_h,ad);
    end
%     try
%         uiwait(fig);
%     catch
%         if ishandle(fig)
%             delete(fig)
%         end
%     end
end
%%
%

function ad=Print(ad,option)
     moviename=['View-',datestr(now),'.png'];
     ind=strfind(moviename,' ');
     moviename(ind)='T';
     ind=strfind(moviename,':');
     moviename(ind)='-';
%      moviename=fullfile(pwd,moviename);
     imwrite(ad.mix,moviename);
     disp(['Saved as ',moviename]);
end

function ad=doSelectMorphogen(ad,option)
    if option==1
        % next
        ad.imorph=ad.imorph+1;
        set(ad.handles.Morphogen,'value',ad.imorph);
    else
        % pick from list
        ad.imorph=get(ad.handles.Morphogen,'value');
    end
    list=get(ad.handles.Morphogen,'string');
    ad.morph=list{ad.imorph};
    ad=update(ad,ad.morph);
end

function ad=update(ad,morph)
    ad.m = leaf_plot( ad.m,...
         'doclip',get(ad.handles.doClip,'value'),...
        ... %'doclip',get(ad.handles.clipCheckbox,'Value')==1,...
        'morphogen',morph); 
    ad.morph=morph;
    disp(morph)
%     if get(ad.handles.FEEdges,'value')
%         set(ad.m.plothandles.meshhandles,'LineStyle','none')
%     else
%         set(ad.m.plothandles.meshhandles,'LineStyle','-')
%     end
    drawnow
    M=mygetframe;
    if ~isfield(ad,'mix')
        ad.mix=ones(size(double(M.cdata)));
        image(ad.mix,'parent',ad.handles.axes1)
        XX=double(M.cdata)/255;
    else
        XX=imresize(double(M.cdata)/255,[size(ad.mix,1),size(ad.mix,2)]);
    end
    if get(ad.handles.IncludeBlack,'value')==0 || get(ad.handles.SoftHatch,'value')
        ind=find(XX<0.05);
        XX(ind)=1;
    end    
    [rows,cols,planes]=size(ad.mix);
    X=reshape(XX,rows*cols,3);
    mix=reshape(ad.mix,rows*cols,3);
    if ~isfield(ad,'automask')
        ad.automask=zeros(size(XX));
        ad.automask([1:9:end,2:9:end,3:9:end,4:9:end],:)=1;
    end
    if get(ad.handles.MachineDrawn,'value')==1
        ad.automask=zeros(size(XX));
        ad.automask([1:9:end,2:9:end,3:9:end,4:9:end],:)=1;
    else
        temp=double(imread('texturetile_default_pencil.bmp'))/255;
        ad.automask=imresize(temp,[size(ad.mix,1),size(ad.mix,2)]);
        ii=find(ad.automask>1);
        ad.automask(ii)=1;
        ii=find(ad.automask<0);
        ad.automask(ii)=0;
        ad.automask=double(ad.automask>0.85);
    end
    Y=min(X')';
    ind=find(Y(:,1)<0.99);
    if get(ad.handles.NoHatch,'value')~=1
        mask=ad.automask;
        MM=imrotate(mask,ad.alpha,'nearest','crop');
        MS=reshape(MM,rows*cols,3);
        maskrange=find(MS==1);
        ind=intersect(ind,maskrange);
    end
    switch ad.cn
        case 'r'
            mix(ind,1)=mix(ind,1).*(X(ind,1));
            mix(ind,2)=mix(ind,2).*(X(ind,2));
            mix(ind,3)=mix(ind,3).*(X(ind,3));
        case 'g'
            mix(ind,1)=mix(ind,1).*(X(ind,2));
            mix(ind,2)=mix(ind,2).*(X(ind,1));
            mix(ind,3)=mix(ind,3).*(X(ind,3));
        case 'b'
            mix(ind,1)=mix(ind,1).*(X(ind,2));
            mix(ind,2)=mix(ind,2).*(X(ind,3));
            mix(ind,3)=mix(ind,3).*(X(ind,1));
    end
    ad.tempmix=reshape(mix,[rows,cols,planes]);
    if get(ad.handles.SoftHatch,'value')
        h=fspecial('gaussian',9,1);
        ad.tempmix=convn(ad.tempmix,h,'same');
    end
    image(ad.tempmix,'parent',ad.handles.axes1);
    set(ad.handles.Fix,'BackgroundColor',[0.8,0.5,0.5]);
end

function ad=doFix(ad,option)
    if option==0
        ad.mix=ad.tempmix;
    else
        ad.mix=ones(size(ad.tempmix));
        ad=update(ad,ad.morph);
    end
    set(ad.handles.Fix,'BackgroundColor','w');
end

function ad=setupAxes(ad)
    % Plot axes
    ad.m.pictures = [];%fig;
    ad.m = leaf_plot( ad.m); %fig
    ad.GFtbox_fig=gcf;
    pos=get(gcf,'position');
    pos(3:4)=[800 800];
    scrsz = get(0,'ScreenSize');
    set(gcf,'position',[1 scrsz(4)/2 scrsz(3)/4 (scrsz(4)/2)-100]);
    %set(gcf,'title','Please do not resize this window');
    cameratoolbar;
%     F=mygetframe(gcf);
%     ad.mix=ones(size(double(F.cdata)));
%     image(ad.mix,'parent',ad.handles.axes1)
%     x=F.cdata;
%     image(double(x)/255,'parent',ad.handles.axes1)
    axis(ad.handles.axes1, 'off');
    ad=doColour(ad,'r');
end

function ad=doColour(ad,cn)
    set(ad.handles.Red,'value',0);
    set(ad.handles.Green,'value',0);
    set(ad.handles.Blue,'value',0);
    switch cn
        case 1
            cn='r';
            set(ad.handles.Red,'value',1);
        case 2
            cn='g';
            set(ad.handles.Green,'value',1);
        case 3
            cn='b';
            set(ad.handles.Blue,'value',1);
    end
    set(ad.handles.NoHatch,'BackgroundColor',cn);
    ad.cn=cn;
    ad=update(ad,ad.morph);
end

function ad=doHatch(ad,option)
    set(ad.handles.NoHatch,'value',0);
    set(ad.handles.Hatch1,'value',0);
    set(ad.handles.Hatch2,'value',0);
    set(ad.handles.Hatch3,'value',0);
    set(ad.handles.Hatch4,'value',0);
    set(ad.handles.Hatch5,'value',0);
    switch option
        case 0
            set(ad.handles.NoHatch,'value',1);
        case 1
            set(ad.handles.Hatch1,'value',1);
        case 2
            set(ad.handles.Hatch2,'value',1);
        case 3
            set(ad.handles.Hatch3,'value',1);
        case 4
            set(ad.handles.Hatch4,'value',1);
        case 5
            set(ad.handles.Hatch5,'value',1);
    end
    ad.hatch=option;
    ad.alpha=(option-1)*30;
    ad=update(ad,ad.morph);
end

function handles = setupcallbacks(handles,ListOfMorphogens)
    % Setup the callback handles
    set(handles.Morphogen, 'callback', [mfilename,'(''doSelectMorphogen'',0);'],...
        'string',ListOfMorphogens);
    set(handles.NextMorphogen, 'callback', [mfilename,'(''doSelectMorphogen'',1);']);
    set(handles.MachineDrawn, ...
        'string',{'Machine hatch','Hand hatch'});
%     set(handles.MachineDrawn, 'callback', [mfilename,'(''doMachineDrawn'',0);'],...
%         'string',{'Machine hatch','Hand hatch'});
    set(handles.doClip, 'callback', [mfilename,'(''doClip'',0);'],'value',1);
%     set(handles.clipCheckbox, 'callback', [mfilename,'(''doClip'',0);'],'value',1);
    set(handles.FEEdges, 'callback',[mfilename,'(''doFEEdges'',0);'],'value',1);
    set(handles.Blue, 'callback', [mfilename,'(''doColour'',3);']);
    set(handles.Green, 'callback', [mfilename,'(''doColour'',2);']);
    set(handles.Red, 'callback', [mfilename,'(''doColour'',1);'],'value',1);
    set(handles.NoHatch, 'callback', [mfilename,'(''doHatch'',0);'],'value',1);
    set(handles.Hatch1, 'callback', [mfilename,'(''doHatch'',1);']);
    set(handles.Hatch2, 'callback', [mfilename,'(''doHatch'',2);']);
    set(handles.Hatch3, 'callback', [mfilename,'(''doHatch'',3);']);
    set(handles.Hatch4, 'callback', [mfilename,'(''doHatch'',4);']);
    set(handles.Hatch5, 'callback', [mfilename,'(''doHatch'',5);']);
    set(handles.Hatch6, 'callback', [mfilename,'(''doHatch'',6);']);
    set(handles.Fix, 'callback', [mfilename,'(''doFix'',0);']);
    set(handles.Clear, 'callback', [mfilename,'(''doFix'',1);']);
    set(handles.Print, 'callback', [mfilename,'(''Print'',1);']);
    set(handles.IncludeBlack,'value',1 );
end
%%%%%
