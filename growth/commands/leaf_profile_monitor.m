function [m,MonData]=leaf_profile_monitor(m,varargin) %realtime,RegionLabels,Morphogens,start_figno)
    %function  m=leaf_profile_monitor(m,realtime,RegionLabels,Morphogens,start_figno)
    %monitor morphogen levels at a set of vertices
    %
    %m, mesh
    %RegionLabels, vertices to be monitored as designated by cell array of strings, i.e. region labels
    %Morphogens, cell array of strings, i.e. uppercase morphogen names to
    %   be monitored. There should be one RegionLabels string for each
    %   Morphogens string
    %Vertlabels, if true then display vertex numbers in each regionlabel on
    %         the mesh default false
    %start_figno, default figure 1 (Must open a fig even if just monitoring to file)
    %
    %MonData, optional output of data structure
    % For example:
%               pathname: 'D:\ab\Matlab stuff\Growth models\GPT_MeasureGrowth_20121203\snapshots'
%               filename: 'monitor--03-Dec-2012-17-39-16.xls'
%     CurrentExcelColumn: 5
%             vertex_set: {[5x1 double]}
%                  index: {[1]}
%             list_order: {[1 2 3 4 5]}
%            regionlabel: {'ID_MID'}
%                 ListOK: {[1]}
%                Results: [1x1 struct]
%                Results.REGN: {'ID_MID'}
%                  Results.XYZ: {[5x3 double]}
%                 Results.XYZA: {[5x3 double]}
%                 Results.XYZB: {[5x3 double]}
%                    Results.X: {[5 5 5 5 5]}
%                    Results.Y: {[5x1 double]}
%                    Results.Z: {[]}
%                    Results.D: {[5x1 double]} % distances between vertices
%                    Results.G: {[]}
%     Results.XYZ_LegendString: ''
%       Results.D_LegendString: {'      ID_MID: intervals'}
%       Results.G_LegendString: []
%                theaxes: [0 1.1410e+03 1.1420e+03]
%            InitialMaxD: 0.5061
%                  LastD: {[5x1 double]}    
    %e.g.
    % monitor properties of vertices
    %     m=leaf_profile_monitor(m,... % essential
    %         'REGIONLABELS',{'V_PROFILE1','V_PROFILE2'},... % essential
    %         'MORPHOGENS',{'S_LEFTRIGHT','S_CENTRE'},... % optional  (one element per REGIONLABEL)
    %         'VERTLABELS',false,'FigNum',1,'EXCEL',true,'MODELNAME',modelname); % optional (file in snapshots directory')
    %
    %     or if you want to limit the time(s) over which it runs
    %     if realtime>5
    %         m=leaf_profile_monitor(m,... % essential
    %             'REGIONLABELS',{'V_PROFILE1','V_PROFILE2'},... % essential
    %             'MORPHOGENS',{'S_LEFTRIGHT','S_CENTRE'},... % optional  (one element per REGIONLABEL)
    %             'VERTLABELS',false,'FigNum',1,'MATFILE',true,'MODELNAME',modelname); % optional (file in snapshots directory')
    %     end
    %
    %   Topics: Simulation.
    %
    % J. Andrew Bangham, 2011
    
    MonData = [];
    
    if isempty(m), return; end
    
    GFTh=findobj(0,'tag','GFTwindow');
    GFTbox_uistate = uisuspend(GFTh,false);
    
    start_figno=1;
    if length(varargin)<3
        error('leaf_vertex_set_monitor: insufficient arguments');
    end
    MonData=struct;
    windowwidth=5;
    vertlabels=false;
    distance_along_line=true;
    morphogen_levels=false;
    Morphogens={};
    growth=true;
    excel=false;
    matfile=false;
    monitor=true;
    modelname='';
    realtime = m.globalDynamicProps.currenttime;
    zerotime=0;
    for i=1:2:length(varargin)
        name=upper(varargin{i});
        arg=varargin{i+1};
        switch name
            case 'MODELNAME'
                modelname=arg;
            case 'MONITOR'
                monitor=arg;
            case 'MATFILE'
                matfile=arg;
            case 'EXCEL'
                excel=arg;
            case 'DISTANCE'
                distance_along_line=arg;
            case 'GROWTH'
                growth=arg;
            case 'VERTLABELS'
                vertlabels=arg;
            case 'ZEROTIME'
                zerotime=arg;
            case 'REGIONLABELS'
                if ~iscell(arg)
                    error([name,' should be a cell array']);
                end
                RegionLabels=upper(arg);
            case 'MORPHOGENS'
                if ~iscell(arg)
                    error([name,' should be a cell array']);
                end
                Morphogens=upper(arg);
                morphogen_levels=true;
            case 'FIGNUM'
                start_figno=arg;
            case 'WINDOW'
                windowwidth=arg;
                %             case 'MARK'
                %                 marker=arg{2};
                %                 region=arg{1};
        end
    end
    % Error checking
    N=length(RegionLabels);
    if N<1 %~=length(Morphogens)
        error('Should be at least one region');
    end
    % Should check that regions are legitimate
    for i=N
        if ~isfield(m.mgenNameToIndex,RegionLabels{i});
            error(sprintf('%s is not a valid morphogen name',Regionlabels{i}));
        end
    end
    if any(growth==true)
        if N~=length(growth)
            growth=logical(ones(size(RegionLabels)));
        end
    end
    if any(distance_along_line==true)
        if N~=length(distance_along_line)
            distance_along_line=logical(ones(size(RegionLabels)));
        end
    end
    if length(distance_along_line)~=N
        distance_along_line=false(zeros(size(RegionLabels)));
    end
    if length(growth)~=N
        growth=false(zeros(size(RegionLabels)));
    end
    % Are the regions valid?
    regionOK=true;
    for i=1:N
        % first identify the vertices and their positions along a line
        regionlabel=upper(RegionLabels{i});
        [monitor1_i,monitor1_p,monitor1_a,monitor1_l] = getMgenLevels( m, regionlabel);
        vertex_set=find(monitor1_l>=0.99);%*max(monitor1_l(:)));
        if isempty(vertex_set)
            disp(sprintf('Please designate line region for profile %s by setting a line of vertices to 1', regionlabel))
            regionOK=false;
        end
    end
    old_figure=gcf;
    if ~regionOK
        if ishandle(start_figno)
            clf(start_figno);
            set(start_figno,'userdata',[]);
        end
    else
        if ishandle(start_figno)
            MonData=get(start_figno,'userdata');
        else
            figure(start_figno);
            MonData=[];
            set(start_figno,'userdata',MonData);
        end
        if isempty(MonData)
            projdirectory= m.globalProps.projectdir;
            modelprojectname= m.globalProps.modelname;
            MonData.pathname=fullfile(projdirectory,modelprojectname,'snapshots');
            str=datestr(now);
            str2=regexprep(str, ' ', '-');
            str3=regexprep(str2, ':', '-');
            MonData.filename=['monitor-',modelname,'-',str3,'.xls'];
            MonData.CurrentExcelColumn=1;
            % find lists of vertices to be monitored
            MonData=FindVertexLists(m,RegionLabels,MonData,vertlabels);
            set(start_figno,'userdata',MonData);
        else
            MonData.CurrentExcelColumn=MonData.CurrentExcelColumn+1;
        end
        % collect data along the vertex lists into X,Y,Z,D,G
        
        MonData=GetResults(m,MonData,N,RegionLabels,Morphogens,...
            distance_along_line,growth,morphogen_levels);
        % ready to plot
        %if monitor (% Must create figure in order to store local data
        MonData=PlotMonitor(m,MonData,morphogen_levels,...
            distance_along_line,growth,start_figno,Morphogens);
        %old_current_axis
        set(start_figno,'UserData',MonData);
        figure(old_figure);
        %end
        % ready to save
        if excel
            SaveToSpreadsheet(MonData,morphogen_levels,Morphogens,RegionLabels,modelname);
        end
        if matfile
            SaveToMatFile(MonData,morphogen_levels,Morphogens,RegionLabels,modelname,realtime);
        end
    end
    %uirestore(GFTbox_uistate);
end

function  SaveToMatFile(MonData,morphogen_levels,Morphogens,RegionLabels,modelname,realtime)
    %
    %     % one sheet for each of results
    %
    %MonData.Results
    % Regions are placed on below another
    N=length(MonData.Results.Y);
    Rows=3;
    for i=1:N
        len(i)=length(MonData.Results.Y{i});
        if i==1
            RegionStartRows(i)=Rows;
        else
            RegionStartRows(i)=Rows+len(i-1)+3;
        end
    end
    t=MonData.Results.X{1};
    colstr=number2excelcolumn(MonData.CurrentExcelColumn);
    filename=fullfile(MonData.pathname,MonData.filename(1:end-4));
    if ~exist(filename)==7
        mkdir(filename);
    end
    D=dir(fullfile(filename,'*.mat'));
    if isempty(D)
        mkdir(filename);
    end
    subfilename=fullfile(filename,['Data',stageTimeToText(realtime)]);
    save([subfilename,'.mat'],'MonData','-mat');
end

function  SaveToSpreadsheet(MonData,morphogen_levels,Morphogens,RegionLabels,modelname)
    %
    %     % one sheet for each of results
    %
    %MonData.Results
    % Regions are placed on below another
    N=length(MonData.Results.Y);
    Rows=3;
    for i=1:N
        len(i)=length(MonData.Results.Y{i});
        if i==1
            RegionStartRows(i)=Rows+1;
        else
            RegionStartRows(i)=Rows+1+len(i-1)+3;
        end
    end
    t=MonData.Results.X{1};
    colstr=number2excelcolumn(MonData.CurrentExcelColumn);
    filename=fullfile(MonData.pathname,MonData.filename);
    for i=1:N
        Y=MonData.Results.Y{i};
        WriteToSpreadsheet('Distances',RegionLabels{i},t(end),filename,MonData.Results.Y{i},colstr,RegionStartRows(i),modelname);
        WriteToSpreadsheet('Inter-vertex',RegionLabels{i},t(end),filename,MonData.Results.D{i},colstr,RegionStartRows(i),modelname);
        WriteToSpreadsheet('Growth',RegionLabels{i},t(end),filename,MonData.Results.G{i}*1000,colstr,RegionStartRows(i),modelname);
        if morphogen_levels
            WriteToSpreadsheet(Morphogens{i},RegionLabels{i},t(end),filename,MonData.Results.Z{i},colstr,RegionStartRows(i),modelname);
        end
    end
end

function WriteToSpreadsheet(SheetLabel,RegionLabel,t,filename,Y,colstr,RegionStartRows,modelname)
    columnstr={[SheetLabel,' ',modelname];RegionLabel;t};
    range=[colstr,'1',':',colstr,'3'];
    warning off MATLAB:xlswrite:AddSheet
    warning off MATLAB:xlswrite:NoCOMServer
    [status1a,msginfo1a] = xlswrite(filename,columnstr(1),SheetLabel,[colstr,'1',':',colstr,'1']);
    [status1b,msginfo1b] = xlswrite(filename,columnstr(2),SheetLabel,[colstr,'2',':',colstr,'2']);
    [status1c,msginfo1c] = xlswrite(filename,columnstr(3),SheetLabel,[colstr,'3',':',colstr,'3']);
    
    endrow=RegionStartRows+length(Y)-1;%+3+1;
    range=[colstr,num2str(RegionStartRows),':',colstr,num2str(endrow)];
    %columnstr={'Distances';RegionLabels{i};t(1); num2cell(Y)};
    columnstr=num2cell(Y);
    warning off MATLAB:xlswrite:AddSheet
    [status2,msginfo2] = xlswrite(filename,columnstr,SheetLabel,range);
end

function letters=number2excelcolumn(column)
    a=26;
    if column>a
        b=floor((column-1)/a);
        letter1=char(64+1+rem(b-1,a));
    else
        letter1=' ';
    end
    letter2=char(64+1+rem(column-1,a));
    letters=[letter1,letter2];
end

function  MonData=PlotMonitor(m,MonData,morphogen_levels,...
        distance_along_line,growth,start_figno,Morphogens)
    colours='crgbmk';
    ListOK=MonData.ListOK{1};
    realtime = m.globalDynamicProps.currenttime;
    if ListOK
        titlestr=sprintf('time=%f ',realtime);
        markers='*odsph';
        % Setup axes for plotting
        if ~isfield(MonData,'theaxes')
            if morphogen_levels
                MonData.theaxes(1)=subplot(1,3,1,'parent',start_figno);%axes('parent',start_figno);
                pos=get(MonData.theaxes(1),'position');
                pos(2)=0.3;
                pos(4)=0.5;
                set(MonData.theaxes(1),'position',pos);
            end
            if distance_along_line
                MonData.theaxes(2)=subplot(1,3,2,'parent',start_figno);%axes('parent',start_figno);
                pos=get(MonData.theaxes(2),'position');
                pos(2)=0.3;
                pos(4)=0.5;
                set(MonData.theaxes(2),'position',pos);
            end
            if growth
                MonData.theaxes(3)=subplot(1,3,3,'parent',start_figno);%axes('parent',start_figno);
                pos=get(MonData.theaxes(3),'position');
                pos(2)=0.3;
                pos(4)=0.5;
                set(MonData.theaxes(3),'position',pos);
            end
        end
        % plot
        if morphogen_levels
            cla(MonData.theaxes(1));
            set(MonData.theaxes(1),'visible','on')
            for i=1:length(MonData.Results.Y)
                mark=markers(1+rem(i,length(markers)));
                y=MonData.Results.Y{i};
                z=MonData.Results.Z{i};
                titlestr=sprintf('%s %s=%2.1f, ',titlestr,Morphogens{i},max(z(:)));
                plot(MonData.theaxes(1),y(:)/max(y(:)),z(:)/max([z(:);1]),'-',...
                    'marker',mark,'color',colours(1+rem(i,length(colours))));
                hold(MonData.theaxes(1),'on');
            end
            MonData.thelegend1=legend(MonData.theaxes(1),...
                MonData.Results.XYZ_LegendString,'location','SouthOutside',...
                'interpreter','none','fontsize',7);
            op=get(MonData.thelegend1,'OuterPosition');
            op(2)=0.15;
            set(MonData.thelegend1,'OuterPosition',op);
            set(MonData.theaxes(1),'Xlim',[0 1],'Ylim',[0 1]);
            xlabel(MonData.theaxes(1),['distance_along_line along line sampled line (',...
                m.globalProps.modelname,')'],'interpreter','none','fontsize',8);
            ylabel(MonData.theaxes(1),'percent of max','interpreter','none','fontsize',8);
            title (MonData.theaxes(1),titlestr,'interpreter','none','fontsize',8);%sprintf('time=%f',realtime))
        end
        if distance_along_line
            cla(MonData.theaxes(2));
            set(MonData.theaxes(2),'visible','on')
            MonData.InitialMaxD=0;
            for i=1:length(MonData.Results.Y)
                MonData.InitialMaxD=max([MonData.Results.D{i};MonData.InitialMaxD]);
                mark=markers(1+rem(i,length(markers)));
                y=MonData.Results.Y{i};
                d=MonData.Results.D{i};
                titlestr=sprintf('%s distance, max-min=%f',titlestr,sum(d));
                plot(MonData.theaxes(2),y(2:end)/max(y(:)),d(2:end),'-',...
                    'marker',mark,'color',colours(1+rem(i,length(colours))));
                hold(MonData.theaxes(2),'on');
            end
            scale=MonData.InitialMaxD*1.3;
            ylim=get(MonData.theaxes(2),'Ylim');
            set(MonData.theaxes(2),'Ylim',[0 scale]);
            xlabel(MonData.theaxes(2),['distance_along_line (',m.globalProps.modelname,')'],...
                'interpreter','none','fontsize',8);
            ylabel(MonData.theaxes(2),'Interpoint distance','interpreter','none','fontsize',8);
            title (MonData.theaxes(2),'Interpoint distance aligned with second vertex',...
                'interpreter','none','fontsize',8);%sprintf('time=%f',realtime))
        end
        if growth
            cla(MonData.theaxes(3));
            set(MonData.theaxes(3),'visible','on')
            MonData.InitialMaxD=0;
            if ~isfield(MonData,'LastD')
                MonData.LastD=MonData.Results.D;
                title(MonData.theaxes(3),'Not available until next time point')
            else
                maxdifference=0;
                for i=1:length(MonData.Results.Y)
                    mark=markers(1+rem(i,length(markers)));
                    y=MonData.Results.Y{i};
                    d=MonData.Results.D{i};
                    d0=MonData.LastD{i};
                    difference=d-d0;
                    MonData.Results.G{i}=difference;
                    maxdifference=max([maxdifference;difference]);
                    titlestr=sprintf('%s distance, ',titlestr);
                    plot(MonData.theaxes(3),y(2:end)/max(y(:)),difference(2:end),'-',...
                        'marker',mark,'color',colours(1+rem(i,length(colours))));
                    hold(MonData.theaxes(3),'on');
                end
                
                ylim=get(MonData.theaxes(3),'Ylim');
                if maxdifference>0
                    set(MonData.theaxes(3),'Ylim',[0 maxdifference]);
                end
                xlabel(MonData.theaxes(3),['distance_along_line (',m.globalProps.modelname,')'],...
                    'interpreter','none','fontsize',8);
                ylabel(MonData.theaxes(3),'Interpoint growth','interpreter','none','fontsize',8);
                title (MonData.theaxes(3),'Growth aligned with second vertex',...
                    'interpreter','none','fontsize',8);%sprintf('time=%f',realtime))
            end
        end
    else
        cla(MonData.theaxes(1));
        title(MonData.theaxes(1),'Profile marker is discontinuous')
    end
end

function MonData=GetResults(m,MonData,N,RegionLabels,Morphogens,...
        distance_along_line,growth,morphogen_levels)
    realtime = m.globalDynamicProps.currenttime;
    X=cell(N,1);
    Y=cell(N,1);
    Z=cell(N,1);
    D=cell(N,1);
    G=cell(N,1);
    XYZ_LegendString='';
    XYZ=[];%cell(N,3);
    XYZA=[];%cell(N,3);
    XYZB=[];%cell(N,3);
    REGN=cell(N,1);
    for i=1:N
        ListOK=MonData.ListOK{i};
        vertex_set=MonData.vertex_set{i};
        index=MonData.index{i};
        list_order=MonData.list_order{i};
        regionlabel=MonData.regionlabel{i};
        ListOK=MonData.ListOK{i};
        [monitor1_i,monitor1_p,monitor1_a,monitor1_l] = getMgenLevels( m, regionlabel);
        numvert=length(vertex_set);
        if ~ListOK
            error('something wrong');
        else
            % now work along the line estimating distance_along_line from origin of line
            origin=m.nodes(vertex_set(index),:);
            last_point=origin;
            y=zeros(numvert,1);
            vertices=zeros(numvert,3);
            verticesSideA=zeros(numvert,3);
            verticesSideB=zeros(numvert,3);
            total_so_far=0;
            for k=1:numvert
                vi = vertex_set(list_order(k));
                point=m.nodes(vi,:);
                vertices(k,:)=point;% midpoints of the prism - i.e. 3 vertices
                verticesSideA(k,:)=m.prismnodes(2*vi-1,:); % odd are A surface
                verticesSideB(k,:)=m.prismnodes(2*vi,:); % even are B surface
                total_so_far=total_so_far+sqrt(sum((point-origin).^2));
                y(k)=total_so_far;
                origin=point;
            end
            REGN{i}=regionlabel;
            XYZ{i,1}=vertices;
            XYZA{i,1}=verticesSideA;
            XYZB{i,1}=verticesSideB;
            Y{i}=y; % distance_along_line along line
            %         y=1:numvert; %data(i).ploty(1:data(i).index,:);
            if i==1 % graph scaling
                MaxSoFar=zeros([N,1]);
                MinSoFar=1000*ones([N,1]);
            end
            % next set up the time axis
            x=repmat(realtime,1,numvert); %data(i).plotx(1:data(i).index,:);
            X{i}=x; % time
            if morphogen_levels
                
                % finally identify the morphogen levels to be plotted on the ordinate
                morphogen=upper(Morphogens{i});
                [morph_i,morph_p,morph_a,morph_l] = getMgenLevels( m, morphogen );
                [Dpar,Dper] = averageConductivity( m, morph_i );
                Diffusion=sprintf('%4.4f,',[Dpar Dper]);
                A=sprintf('%4.4f,',MEAN(m.mgen_absorption(:,morph_i)));
                XYZ_LegendString{i}=sprintf('%12s:%12s_l, A=%s D=(%s)',...
                    regionlabel(1:min(length(regionlabel),12)),...
                    morphogen(1:min(length(morphogen),12)),...
                    A,Diffusion);
                z=morph_l(vertex_set(list_order)); %data(i).plotz(1:data(i).index,:);
                z(isnan(z))=0;
                Z{i}=z; % morphogen level
            end
        end
    end
    if distance_along_line(1)
        for i=1:N
            vertex_set=MonData.vertex_set{i};
            index=MonData.index{i};
            list_order=MonData.list_order{i};
            regionlabel=MonData.regionlabel{i};
            ListOK=MonData.ListOK{i};
            [monitor1_i,monitor1_p,monitor1_a,monitor1_l] = getMgenLevels( m, regionlabel);
            numvert=length(vertex_set);
            origin=m.nodes(vertex_set(index),:);
            d=zeros(numvert,1);
            for k=1:numvert
                point=m.nodes(vertex_set(list_order(k)),:);
                d(k)=sqrt(sum((point-origin).^2));
                origin=point;
            end
            D{i}=d;
            D_LegendString{i}=sprintf('%12s: intervals',...
                regionlabel(1:min(length(regionlabel),12)));
        end
    else
        D_LegendString=[];
    end
    if 0 %growth(1)
        for i=1:N
            vertex_set=MonData.vertex_set{i};
            index=MonData.index{i};
            list_order=MonData.list_order{i};
            regionlabel=MonData.regionlabel{i};
            ListOK=MonData.ListOK{i};
            [monitor1_i,monitor1_p,monitor1_a,monitor1_l] = getMgenLevels( m, regionlabel);
            numvert=length(vertex_set);
            origin=m.nodes(vertex_set(index),:);
            g=zeros(numvert,1);
            for k=1:numvert
                point=m.nodes(vertex_set(list_order(k)),:);
                d(k)=sqrt(sum((point-origin).^2));
                origin=point;
            end
            G{i}=g;
            G_LegendString{i}=sprintf('%12s: intervals',...
                regionlabel(1:min(length(regionlabel),12)));
        end
    else
        G_LegendString=[];
    end
    Results.REGN=REGN;
    Results.XYZ=XYZ;
    Results.XYZA=XYZA;
    Results.XYZB=XYZB;
    Results.X=X;
    Results.Y=Y;
    Results.Z=Z;
    Results.D=D;
    Results.G=G;
    Results.XYZ_LegendString=XYZ_LegendString;
    Results.D_LegendString=D_LegendString;
    Results.G_LegendString=G_LegendString;
    MonData.Results=Results;
end

function MonData=FindVertexLists(m,RegionLabels,MonData,vertlabels)
    N=length(RegionLabels);
    for i=1:N
        % first identify the vertices and their positions along a line
        % this has to be done every time since there subdivision might have
        % increased the number of nodes
        regionlabel=upper(RegionLabels{i});
        [monitor1_i,monitor1_p,monitor1_a,monitor1_l] = getMgenLevels( m, regionlabel);
        vertex_set=find(monitor1_l>=0.99);%*max(monitor1_l(:)));
        numvert=length(vertex_set);
        %         if ~ MonData.firsttimeflag
        %             list_order=1:numvert;
        %             error_counter(i)=0;
        %         else
        % find the vertex sequece and start vertex
        if exist('list')
            clear list
        end
        startend=[];
        for k=1:numvert
            list{k}=[];
            [ii,jj]=find(m.edgeends==vertex_set(k));
            % ii indexes all edges that include this vertex
            % how many of the other vertices in vertex_sets
            % are in these edges
            for kk=1:length(ii)
                edge=m.edgeends(ii(kk),:); % contains current vertex
                % and neighbour, is this one in the list of other vertices
                nn=intersect(edge,vertex_set);%setdiff(vertex_set,vertex_set(k)))
                list{k}=unique([list{k},nn']);
            end
            startend(k)=length(list{k});
        end
        % pick one end point
        if ~exist('startend')
            error('ERROR: The morphogen being used to set the profile must have some vertices with values set to one');
        end
        if isempty(startend)
            fprintf(1,'leaf_vertex_set_monitor  %s',regionlabel)
            error('ERROR: The profile marker does not have two ends');
        end
        if length(startend)>2
            endpoints=find(startend==2);
            if isempty(endpoints)
                fprintf(1,'leaf_vertex_set_monitor ');
                for i=1:length(RegionLabels)
                    fprintf(1,' %s ',RegionLabels{i});
                end
                fprintf(1,'startend = %d ',startend)
                error('cannot find start of morphogen profile')
            end
            endpoint=endpoints(1);
        else
            endpoint=startend(1);
            endpoints=startend(1);
        end
        if length(endpoints)>1
            % edge described in list{endpoint} must also exist in one other
            % list
            % for k=1:length(list),disp(list{k}),end
            list_order=endpoint;
            ko=1;
            ed=list{list_order(ko)}; % first current edge, look for next one
            error_counter(i)=0;
            while (length(list_order)<numvert) & (error_counter<length(m.edgeends))
                for k=1:numvert % look through list
                    if ~any(k==list_order) % for any edge not already used
                        eds=list{k}; % this might contain a matching edge
                        if length(intersect(ed,eds))==2
                            ko=ko+1; % yes it does
                            list_order(ko)=k; % so add it to the list_order
                            % next edge is this
                            new_node=setdiff(eds,ed);
                            % with one of the others
                            possible1=[new_node,ed(1)];
                            possible2=[new_node,ed(2)];
                            % so look through those remaining in list
                            for kk=1:numvert
                                if ~any(kk==list_order)
                                    if length(intersect(list{kk},possible1))==2
                                        ed=possible1;
                                        break % got it
                                    end
                                    if length(intersect(list{kk},possible2))==2
                                        ed=possible2;
                                        break % got it
                                    end
                                end
                            end
                        end
                    end
                end
                error_counter(i)=error_counter(i)+1;
            end
            %         end
            ListOK{i}=error_counter(i)<length(m.edgeends) && numvert==length(list_order);
        else
            list_order(1)=1;
            ListOK{i}=true;
        end
        if ~ListOK{i}
            error(sprintf('RegionLabel %s is discontinuous - divide into separate regions',regionlabel))
        else
            if  vertlabels
                % the following plots the vertex numbers onto the mesh
                % for checking the algorithm
                GFtboxAxes=getGFtboxAxes(m);
                if ishandle(GFtboxAxes)
                    axes(GFtboxAxes);
                    hold(GFtboxAxes,'on');
                    for kk=1:numvert
                        k=list_order(kk);
                        th=text(m.nodes(vertex_set(k),1),...
                            m.nodes(vertex_set(k),2),...
                            m.nodes(vertex_set(k),3),...
                            num2str(vertex_set(k)),'visible','on','fontsize',12,'color','b');
                        if k==1
                            set(th,'fontsize',14,'color','r');
                        end
                    end
                    % figure(start_figno);
                end
            end
            
            %         n=m.nodes(vertex_set,:);
            %         d=n(:,1).^2+n(:,2).^2+n(:,3).^3;
            %         [D,index]=max(d);
            originInd=find(monitor1_p>1.5);
            if isempty(originInd)
                index=list_order(1);
                originInd=vertex_set(index);
                monitor1_p(originInd)=2; % mark the origin of the line
                %monitor1_p(vertex_set(index))=2; % mark the origin of the line
                m.morphogens(:,monitor1_i) = monitor1_p;
            else
                index=find(vertex_set==originInd);
            end
            MonData.vertex_set{i}=vertex_set;
            MonData.index{i}=index;
            MonData.list_order{i}=list_order;
            MonData.regionlabel{i}=regionlabel;
        end
        MonData.ListOK=ListOK;
    end
end