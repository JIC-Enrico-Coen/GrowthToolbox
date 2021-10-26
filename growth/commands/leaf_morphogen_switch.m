function     [m, gm_l]=leaf_morphogen_switch(m,varargin)
    %function     gm_l=leaf_morphogen_switch(m,varargin)
    %
    %usage
    % Here the default on and off values of 0 and 1 are used
%         [m,tube_l]=leaf_morphogen_switch(m,...
%             'StartTime',OnsetOfTubeGrowth,'EndTime',FinishTubeGrowth,...
%             'Morphogen_l','tube','RealTime',realtime);
% Alternatively, these can be specified
%         [m,basemid_l]=leaf_morphogen_switch(m,...
%             'StartTime',OnsetOfTubeGrowth,'EndTime',FinishTubeGrowth,...
%             'Morphogen_l','basemid','RealTime',realtime,...
%             'OnValue',1.0,'OffValue',0.0);
%
%   Topics: Morphogens.

    if isempty(m), return; end
    counter=ones(1,4);
    newOnvalue=1;
    newOffvalue=0;
    k=0;
    for i=1:2:length(varargin)
        name=upper(varargin{i});
        arg=varargin{i+1};
        k=k+1;
        switch name
            case 'STARTTIME'
                counter(k)=0;
                St=arg;
            case 'ENDTIME'
                counter(k)=0;
                Et=arg;
            case 'MORPHOGEN_L'
                counter(k)=0;
                morphogen_label=upper(arg);
                [monitor1_i,monitor1_p,monitor1_a,monitor1_l] = getMgenLevels( m, morphogen_label);
            case 'REALTIME'
                counter(k)=0;
                realtime=arg;
            case 'ONVALUE'
                counter(k)=0;
                newOnvalue=arg;
            case 'OFFONVALUE'
                counter(k)=0;
                newOffvalue=arg;
        end
    end
    if any(counter)
        disp(counter)
        error('leaf_morphogen_switch: incorrect number of arguments');
    end
    if realtime>=St && realtime<Et
        gm_l=monitor1_l;
        m = leaf_mgen_modulate( m, 'morphogen', morphogen_label,'switch', newOnvalue);
    else
        gm_l=zeros(size(monitor1_l));
        m = leaf_mgen_modulate( m, 'morphogen', morphogen_label,'switch', newOffvalue);
    end
end

