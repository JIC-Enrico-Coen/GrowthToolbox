function [binsizes,bins] = alphabins( names, maxbin )
%binsizes = alphabins( names, maxbin )
%
% Result is list of indexes saying which bin each name belongs to.
% Names are assumed already sorted.
% No multi-level hierarchy: either no bins required or one level of
% binning.

    MAXBINSIZE = maxbin;

    if length(names) < MAXBINSIZE
        bins = ones(1,length(names));
        return;
    end
    MINBINS = ceil(length(names)/MAXBINSIZE);
    letterbins = zeros(1,26);
    for i=1:length(names)
        j = lower(names(i))-'a'+1;
        letterbins(j) = letterbins(j)+1;
    end
    curbin = 0;
    curbinsize = 0;
    binsizes = [];
    for i=1:26
        if (curbinsize + letterbins(i) > MAXBINSIZE) && (curbinsize > 0)
            curbin = curbin+1;
            binsizes(curbin) = curbinsize;
            curbinsize = letterbins(i);
        else
            curbinsize = curbinsize + letterbins(i);
        end
    end
    if curbinsize > 0
        curbin = curbin+1;
        binsizes(curbin) = curbinsize;
    end
    bins = [];
    for i=1:length(binsizes)
        bins( (end+1):(end+binsizes(i)) ) = i;
    end
end
