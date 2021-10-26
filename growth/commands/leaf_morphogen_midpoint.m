function [m,target_p,TargetMorphArea]=leaf_morphogen_midpoint(m,varargin)
    %function [m,target_p,TargetMorphArea]=morphogen_midpoint(m,varargin)
    %     uses one or two gradient of diffusing morphogen to define
    %     a region in TARGETMORPH. 
    %     initially the region is set to the value 1
    %     However, once it is stable it is set to 2 and 
    %     the interaction function should stop trying to change the midpoint.
    %    
    %     It also defines a region of all vertices > threshold used
    %     to define TARGETMORPH (i.e. all below the midpoint)
    %
    %usage
    %%intersection of two opposing gradients and view clustering
    %[circ2_p,tube_p]=leaf_morphogen_midpoint('DIFF1MORPH',p1_l,...
    %            'DIFF2MORPH',p2_l,'TARGETMORPH',circ2_p,'LABEL','CIRC2','VERBOSE',true);
    %%intersection of two opposing gradients
    %[circ2_p,tube_p]=leaf_morphogen_midpoint('DIFF1MORPH',p1_l,...
    %            'DIFF2MORPH',p2_l,'TARGETMORPH',circ2_p);
    %%find lowpoint in a U shaped diffusing morphogen
    %[mid_p]=leaf_morphogen_midpoint('DIFF1MORPH',midd_p,'TARGETMORPH',mid_
    %p);
    %
    %   Topics: Morphogens.
    
    %
    %J.Andrew Bangham, 2008
    if isempty(m), return; end
    if rem(length(varargin),2)
        error('morphogen_midpoint: incorrect argument list');
    end
    start_figno=2;
    twocount=0;
    diff1=[];
    diff2=[];
    morph1=[];
    morph2=[];
    target_p=[];
    verbose=false;
    TargetMorphArea=[];
    label='';
    threshdt=[];
    thresholdvalue=[];
    tolerance_sd=0.001;
    thresheq=false;
    threshless=false;
    minnumv='';
    ignorename='';
    ignore_p=[];
    TimeConstant=1/0.2; % i.e. 5 steps
    for i=1:2:length(varargin)
        name=upper(varargin{i});
        arg=varargin{i+1};
        switch name
            case 'DIFF1MORPH'
                diff1=arg;
                twocount=twocount+1;
                morph1=name;
            case 'DIFF2MORPH'
                diff2=arg;
                twocount=twocount+1;
                morph2=name;
            case 'TARGETMORPH'
                target_p=arg;
                targetname=name;
            case 'IGNOREREGION'
                ignore_p=arg;
                ignorename=name;
            case 'VERBOSE'
                verbose=arg;
            case 'LABEL'
                label=arg;
            case 'TOLERANCESD'
                tolerance_sd=arg;
            case '=THRESHOLD'
                thresheq=true;
                thresholdvalue=arg;
            case '<THRESHOLD'
                threshless=true;
                threshdt=arg;
            case '>THRESHOLD'
                threshless=false;
                threshdt=arg;
            case 'MINNUMV'
                minnumv=arg;
            case 'FIGNUM'
                start_figno=arg;
            case 'TIMECONSTANT' % in seconds
                TimeConstant=arg/m.globalProps.timestep;
            otherwise
                error('leaf_morphogen_midpoint: unrecognised argument');
        end
    end
    disp(['morphogen_midpoint: label=',label]);
    if max(target_p)<1.5
        if twocount==2
            diff1=diff1/max(diff1);
            diff2=diff2/max(diff2);
            dists=(diff1-diff2).^2;
        else
            if isempty(diff1)
                diff1=diff2;
            end
            if thresheq
                if max(diff1)==0
                    dists=ones(size(diff1));
                else
                    dists=((diff1-min(diff1))/(max(diff1)-min(diff1)))-thresholdvalue;
                    dists=dists.*dists;
                end
            else
                dists=diff1/max(diff1);
            end
        end
        % ignore regions if required
        if ~isempty(ignore_p)
            dists(ignore_p>0.5)=NaN;
        end
        % look for clusters
        [hst,bins]=hist(dists,length(diff1));
        if verbose
            
            tempfig=gcf;
            figure(start_figno);
            if ~isfield(m,'monitor_figs')
                m.monitor_figs=start_figno;
            else
                if ~any(m.monitor_figs==start_figno)
                    m.monitor_figs(end+1)=start_figno;
                end
                %         disp(sprintf('m.monitor_figs=%d ',m.monitor_figs))
            end
            cla
            if ~isempty(label)
                title(sprintf('clustering for %s',label));
            end
            subplot(3,1,3)
            cla
            hold off
            bar((bins),hst);
        end
        dt=bwdist(hst>0);
        cs=cumsum(hst);
        last_dt=0;
        if isempty(threshdt)
            for i=1:length(hst)
%                 disp(sprintf('%d %f',i,dt(i)))
                if cs(i)>0
                    if (dt(i)<last_dt)
                        break
                    end
                end
                last_dt=dt(i);
            end
            thresholdA=bins(i-1);
            firstpeak=last_dt;
            last_dt=0;
            for ii=i-1:length(hst)
%                 disp(sprintf('%d %f',ii,dt(ii)))
                if dt(ii)<last_dt
                    break
                end
                last_dt=dt(ii);
            end
            last_dt=0;
            for iii=ii:length(hst)
%                 disp(sprintf('%d %f',iii,dt(iii)))
                if cs(iii)>0
                    if (dt(iii)<last_dt)
                        break
                    end
                end
                last_dt=dt(iii);
            end
            thresholdB=bins(iii-1);
            secondpeak=last_dt;
            if firstpeak>secondpeak/10;
                threshold=thresholdA;
            else
                threshold=thresholdB;
            end
                
        else
%             for i=1:length(hst)
%                 if cs(i)>0
%                     if (dt(i)<last_dt) && (dt(i)>threshdt)
%                         break
%                     end
%                 end
%                 last_dt=dt(i);
%             end
            threshold=threshdt;
        end
        if ~isempty(minnumv)
            % go up through histogram until correct number
            % of vertices has been accepted.
            s=0;
            for i=1:length(hst)
                s=s+hst(i);
                if s>=minnumv
                    break
                end
            end
            threshold=bins(i-1);
        end
        TargetMorphLine=zeros(size(dists));
        TargetMorphArea=zeros(size(dists));
        if i>(length(hst)/4)
            threshold=0;
        else
            if verbose
                subplot(3,1,3)
                hold on
                plot((threshold),0,'+r');
                hold off
                xlabel('distance squared')
                subplot(3,1,1)
                cla
                plot(dt)
                hold off
                title('choose threshold that selects leftmost cluster')
                subplot(3,1,2)
                cla
                plot(cs)            
            end
            if isempty(threshdt)
                TargetMorphLine(dists<=threshold)=1;
            elseif threshless
                TargetMorphLine(dists<threshold)=1;
            else
                TargetMorphLine(dists>threshold)=1;
            end                

            sd=std((target_p-TargetMorphLine).^2)
            if (sum(target_p)<1) || (sd>tolerance_sd)
                k=rand(size(target_p))/TimeConstant;
                target_p=target_p.*k+TargetMorphLine.*(1-k);
                MeanDiff1Threshold=max(diff1(dists<threshold));
                TargetMorphArea(diff1>MeanDiff1Threshold)=1;
            else
                target_p(target_p>0.5)=2;
                MeanDiff1Threshold=max(diff1(dists<threshold));
                TargetMorphArea(diff1>MeanDiff1Threshold)=2;
            end
        end
        if verbose
            xlabel('(distance) use nodes with value below red +');
            ylabel('number of vertices');
            figure(tempfig);
        end
    end
end
