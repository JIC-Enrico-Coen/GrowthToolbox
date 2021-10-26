function     [gm_l,gm_p]=leaf_morphogen_pulse(m,varargin)
%[gm_l,gm_p]=leaf_morphogen_pulse(m,varargin)
%
%   Topics: Morphogens.

    if isempty(m), return; end
    counter=ones(1,6);
    k=0;
    Dk=5;
    Uk=1;
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
            case 'DEPENDENTMORPHOGEN'
                counter(k)=0;
                GM=arg;
            case 'PRIMARYMORPHOGEN'
                counter(k)=0;
                PM=arg;
            case 'DELTAT'
                counter(k)=0;
                Dt=arg;
            case 'REALTIME'
                counter(k)=0;
                realtime=arg;
            case 'DOWNRATE'
                Dk=arg;
            case 'UPRATE'
                Uk=arg;
        end
    end
    if any(counter)
        disp(counter)
        error('leaf_morphogen_pulse: incorrect number of arguments');
    end
    DK=Dt/Dk;
    UK=Dt/Uk;
    [pm_i,pm_p,pm_a,pm_l] = getMgenLevels( m, PM );
    [gm_i,gm_p,gm_a,gm_l] = getMgenLevels( m, GM );
%     ind=find(pm_l>0.95*max(pm_l(:)));
    ind=find(pm_l==max(pm_l(:)));
    if realtime>=St && realtime<Et
        gm_p(ind)=gm_p(ind)*(1-UK) + pm_p(ind)*(UK);
        ind=find(gm_p>pm_p);
        if ~isempty(ind)
            gm_p(ind)=pm_p(ind);
        end
    else
        gm_p(ind)=gm_p(ind)*(1-DK);% + Dt*pm_p(ind)*(Uk);
        ind=find(gm_p<0);
        if ~isempty(ind)
            gm_p(ind)=0;
        end
    end
    gm_p(gm_p~=max(gm_p))=0;
    gm_l=gm_p.*gm_a;
end
