function  m=leaf_vertex_set_monitor(m,varargin) %realtime,RegionLabels,Morphogens,start_figno)
    %function  m=leaf_vertex_set_monitor(m,realtime,RegionLabels,Morphogens,start_figno)
    %monitor morphogen levels at a set of vertices
    %
    %m, mesh
    %realtime, time starting at 0
    %RegionLabels, vertices to be monitored as designated by cell array of strings, i.e. region labels
    %Morphogens, cell array of strings, i.e. uppercase morphogen names to
    %   be monitored
    %start_figno, first figure number ... one figure per morphogen
    %
    %e.g.
    %     leaf_vertex_set_monitor(m,'RealTime',realtime,'ZeroTime',zerotime,...
    %         'REGIONLABELS',{'MEDIAL','MEDIAL'},...
    %         'MORPHOGENS',{'KAPAR','KBPAR'},...
    %         'FigNum',4);
    % the  'REGIONLABELS' can be 'SEAM' in which case m.seam is used
%
%   Topics: Simulation.

    if isempty(m), return; end
    start_figno=2;
    if length(varargin)<3
        error('leaf_vertex_set_monitor: insufficient arguments');
    end
    windowwidth=5;
    zerotime=0;
    profilesflag=false; %true;
    allpointsflag=true; %false;
    for i=1:2:length(varargin)
        name=upper(varargin{i});
        arg=varargin{i+1};
        switch name
            case 'ZEROTIME'
                zerotime=arg;
            case 'REALTIME'
                realtime=arg;
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
            case 'FIGNUM'
                start_figno=arg;
            case 'WINDOW'
                windowwidth=arg;
%             case 'MARK'
%                 marker=arg{2};
%                 region=arg{1};
            case 'PROFILES'
                profilesflag=arg;
            case 'ALLPOINTS'
                allpointsflag=arg;
        end
    end
    N=length(RegionLabels);
    if N~=length(Morphogens)
        error('monitor called with unbalanced arguments');
    end
    old_figure=gcf;
    old_current_axis=gca;
    makefigure = false;
    if ~isfield(m,'monitor_figs')
        m.monitor_figs=start_figno;
        makefigure = true;
    else
        if ~any(m.monitor_figs==start_figno)
            m.monitor_figs(end+1)=start_figno;
            makefigure = true;
        end
%         disp(sprintf('m.monitor_figs=%d ',m.monitor_figs))
    end
    if makefigure || ~ishandle(start_figno)
        figure(start_figno);
    end
    theaxes = figureaxes(start_figno);
    if realtime<=zerotime*1.00001
        cla(theaxes);
        set(start_figno,'UserData',[]);
        firsttimeflag=true;
    else
      % cla(theaxes);
        firsttimeflag=false;
    end
    if isempty(theaxes)
        theaxes = axes;
    else
        theaxes = theaxes(1);
    end
    %vertex_set=get(start_figno,'UserData');
    colours='crgbmk';
    for i=1:N
        % first identify the vertices and their positions along a line
        regionlabel=upper(RegionLabels{i});
        if strcmp(regionlabel,'SEAM')
            if firsttimeflag || allpointsflag
%                 ind=find(m.seams);
                vertex_set=unique(m.edgeends(m.seams==1,:));
                set(start_figno,'UserData',vertex_set);
            end
            monitor1_p=zeros(size(m.morphogens,1));
            monitor1_p(vertex_set)=1;
        else
            [monitor1_i,monitor1_p,monitor1_a,monitor1_l] = getMgenLevels( m, regionlabel);
            if firsttimeflag || allpointsflag
                vertex_set=find(monitor1_l>=0.99);%*max(monitor1_l(:)));
                set(start_figno,'UserData',vertex_set);
            end
        end
        numvert=length(vertex_set);
        if ~allpointsflag && ~firsttimeflag
            list_order=1:numvert;
            error_counter(i)=0;
        else
            if exist('list')
                clear list
            end
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
                    list{k}=unique([list{k},nn]);
                end
                startend(k)=length(list{k});
            end
            % pick one end point
            if ~exist('startend')
                error('ERROR: The morphogen being used to set the profile must have some vertices with values set to one');
            end
            if isempty(startend)
                fprintf(1,'leaf_vertex_set_monitor  %s',Morphogens)
                error('ERROR: The profile marker does not have two ends');
            end
            endpoints=find(startend==2);
            if isempty(endpoints)
                fprintf(1,'leaf_vertex_set_monitor ');
                for i=1:length(Morphogens)
                    fprintf(1,' %s ',Morphogens{i});
                end
                fprintf(1,'startend = %d ',startend)
                error('cannot find start of morphogen profile')
            end
            endpoint=endpoints(1);
            
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
        end
        if error_counter(i)<length(m.edgeends) && numvert==length(list_order)
            
            if firsttimeflag
                % the following plots the vertex numbers onto the mesh
                % for checking the algorithm
                current_axis=getGFtboxAxes(m);
                if ishandle(current_axis)
                    axes(current_axis);
                    hold(current_axis,'on');
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

            index=list_order(1);
            %         n=m.nodes(vertex_set,:);
            %         d=n(:,1).^2+n(:,2).^2+n(:,3).^3;
            %         [D,index]=max(d);
            if ~strcmp(regionlabel,'SEAM')
                monitor1_p(vertex_set(index))=2; % mark the origin of the line
                m.morphogens(:,monitor1_i) = monitor1_p;
            end
            % now work along the line estimating distance from origin of line
            origin=m.nodes(vertex_set(list_order(1)),:);
            y=zeros(numvert,1);
            total_so_far=0;
            for k=1:numvert
                point=m.nodes(vertex_set(list_order(k)),:);
                total_so_far=total_so_far+sqrt(sum((point-origin).^2));
                y(k)=total_so_far;
                origin=point;
            end
            Y{i}=y;
            %         y=1:numvert; %data(i).ploty(1:data(i).index,:);
            if i==1 % graph scaling
                MaxSoFar=zeros([N,1]);
                MinSoFar=1000*ones([N,1]);
            end
            % next set up the time axis
            x=repmat(realtime,1,numvert); %data(i).plotx(1:data(i).index,:);
            X{i}=x;
            % finally identify the morphogen levels to be plotted on the ordinate
            morphogen=upper(Morphogens{i});
            [morph_i,morph_p,morph_a,morph_l] = getMgenLevels( m, morphogen );
            D=sprintf('%4.4f ',averageConductivity(m,morph_i));
            A=sprintf('%4.4f ',mean(m.mgen_absorption(:,morph_i)));
            LegendString{i}=['Along ',regionlabel,': Morphogen ',morphogen,' level, A=',A,', D=[',D,']'''];
            z=morph_l(vertex_set(list_order)); %data(i).plotz(1:data(i).index,:);
            z(isnan(z))=0;
            Z{i}=z;
            if profilesflag
                figure(start_figno);
                theaxis = subplot(N+1,1,i);
                plot3(theaxis,x(:),y(:),z(:),'color',colours(1+rem(i,length(colours))));
                hold(theaxis,'on');
                ax=axis(theaxis);
                if realtime>windowwidth
                    ax(1)=realtime-windowwidth;
                else 
                    ax(1)=0;
                end
                ax(4)=max(y(:));
                ax(2)=realtime;
                ax(6)=max([MaxSoFar(:);z(:)]);
                %         ax(5)=-0.5;
                %         ax(6)=ax(6)+0.5;
                setaxis(theaxis,ax);
                title(theaxis,LegendString{i},'interpreter','none');
                setview(theaxis,225,135);
%                 setview(theaxis,-45,-45);
                xlabel(theaxis,'time');
                ylabel(theaxis,'line');
                zlabel(theaxis,'level');
            end
        end
    end
    if all(error_counter<length(m.edgeends))&& numvert==length(list_order)
        if profilesflag
            theaxes = subplot(N+1,1,N+1);
            hold(theaxes,'off');
        end
        cla(theaxes);
        set(theaxes,'visible','on')
        titlestr=sprintf('time=%f ',realtime);
        markers='*odsph';
        for i=1:length(Z)
            mark=markers(1+rem(i,length(markers)));
            y=Y{i};
            z=Z{i};
            %             plot(z,'-*','color',colours(1+rem(i,length(colours))));
            titlestr=sprintf('%s %s=%2.1f, ',titlestr,Morphogens{i},max(z(:)));
%             plot(y(:)/max(y(:)),z(:),'-*','color',colours(1+rem(i,length(colours))));
            plot(theaxes,y(:)/max(y(:)),z(:)/max([z(:);1]),'-',...
                'marker',mark,'color',colours(1+rem(i,length(colours))));
            hold(theaxes,'on');
        end
        legend(theaxes,LegendString,'location','SouthOutside','interpreter','none');
        theaxes = figureaxes(start_figno);
            ax=axis(theaxes(end));
            ax(3)=0;
            setaxis(theaxes(end),ax);
            xlabel(theaxes(end),['distance along line sampled line (model: ',m.globalProps.modelname,')'],'interpreter','none');
            ylabel(theaxes(end),'percent of max','interpreter','none');
            title(theaxes(end),titlestr,'interpreter','none');%sprintf('time=%f',realtime))
%         if ~profilesflag
%             set(theaxes(1),'visible','off');
%         end
%         else
%             ax=axis(theaxes);
%             ax(3)=0;
%             setaxis(theaxes,ax);
%             xlabel(theaxes,['distance along line sampled line (model: ',m.globalProps.modelname,')']);
%             ylabel(theaxes,'percent of max');
%             title(theaxes,titlestr);%sprintf('time=%f',realtime))
%         end
    else
        if profilesflag
            theaxes = subplot(N+1,1,N+1);
            hold(theaxes,'off');
        end
        cla(theaxes);
        title(theaxes,'Profile marker is discontinuous')
    end
    drawnow
    %old_current_axis
    figure(old_figure);
end
