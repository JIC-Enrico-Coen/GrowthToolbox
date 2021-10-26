function  m=leaf_vertex_monitor(m,varargin) %realtime,RegionLabels,Morphogens,figno)
    %m=leaf_vertex_monitor(m,realtime,RegionLabels,Morphogens,figno)
    %   monitor morphogen levels at individual vertices
    %
    %m, mesh
    %realtime, time starting at 0
    %RegionLabels, vertices to be monitored as designated by cell array of strings, i.e. region labels
    %Morphogens, cell array of strings, i.e. uppercase morphogen names to
    %   be monitored
    %figno, figure number ... one figure per morphogen
    %
    %e.g.
    %leaf_vertex_monitor(m,realtime,{'POINT1','POINT2'},{'KAPAR','POLARISER'},1);
%
%   Topics: Simulation.
    
    if isempty(m), return; end
    start_figno=2;
    if length(varargin)<3
        error('leaf_vertex_set_monitor: insufficient arguments');
    end
    zerotime=0;
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
                RegionLabels=arg;
            case 'MORPHOGENS'
                if ~iscell(arg)
                    error([name,' should be a cell array']);
                end
                Morphogens=arg;
            case 'FIGNUM'
                start_figno=arg;
        end
    end
    current_figure=gcf;
    N=length(RegionLabels);
    figure(start_figno);
    data=get(start_figno,'userdata');
    if isempty(data) || realtime<=zerotime*1.000001
        data.index=1;
        data.regions=RegionLabels;
        clf;
    else
        data.index=data.index+1;
    end
    N=length(RegionLabels);
    if N~=length(Morphogens)
        error('monitor called with different number of labels and morphogens');
    end
    data.plotx(data.index)=realtime;
    for i=1:N
        regionlabel=upper(RegionLabels{i});
        [monitor1_i,monitor1_p,monitor1_a,monitor1_l] = getMgenLevels( m, regionlabel);
        ind=find(monitor1_l==max(monitor1_l(:)));
        morphogen=upper(Morphogens{i});
        [morph_i,morph_p,morph_a,morph_l] = getMgenLevels( m, morphogen );
        data.ploty(i,data.index)=max(morph_l(ind));
        LegendStrings{i}=['Region ',regionlabel,':',morphogen];
    end
    cla
    hold on
    colours='rgbcmk';
    markers='x+osd';
    for i=1:size(data.ploty,1)
        colour_i=1+rem(i,length(colours));
        marker_i=1+rem(i,length(markers));
        plot(data.plotx(1:data.index),data.ploty(i,1:data.index),...
            '-','color',colours(colour_i),'marker',markers(marker_i),...
            'MarkerFaceColor',colours(colour_i));       
    end
    ax=axis;
    setaxis(gca,[0,ax(2),-0.5,2.5]);
%     setaxis(gca,[0,ax(2),ax(3)-0.5,ax(4)+0.5]);
    xlabel('time');
    ylabel('morphogen level');
    h=legend(LegendStrings,2,'location','SouthWest');
    set(h,'interpreter','none','fontsize',8);
    set(start_figno,'userdata',data);
    figure(current_figure);
end
