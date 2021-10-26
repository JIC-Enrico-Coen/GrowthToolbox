function signal=NormaliseGrad(signal,localmask,wholemask)
    %function signal=NormaliseGrad(signal,localmask,wholemask)
    %
    %normalise a morphogen gradient found in signal and in 
    %a region localmask so that its values lie in the range
    %0 to 1
    %Set all values outside the region specified by wholemask
    %to 0
    %
    %J.A.Bangham 2009
    
    if nargin<2
        localmask=ones(size(signal));
    end
    if nargin<3
        wholemask=localmask;
    end
    inds=find(localmask>0);
    minsig=min(signal(inds));
    maxsig=max(signal(inds));
    signal(inds)=(signal(inds)-minsig)/(maxsig-minsig);
    signal(wholemask<0.1)=0;
end
