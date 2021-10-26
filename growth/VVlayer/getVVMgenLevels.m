function [i,vvc,vvm,vvw,a,cl,ml,wl] = getVVMgenLevels( m, n )
    i = lookUpVVmgens( m.secondlayer.vvlayer, n );
    if isempty(i)
        fprintf('Missing cellular morphogen %s\n',n);
    else
        i = i(1);
    end

    vvc = m.secondlayer.vvlayer.mgenC(:,i);
    vvm = m.secondlayer.vvlayer.mgenM(:,i);
    vvw = m.secondlayer.vvlayer.mgenW(:,i);
    if m.allMutantEnabled
        a = m.mutantLevel(i);
    else
        a = 1;
    end
    cl = vvc * a;
    ml = vvm * a;
    wl = vvw * a;
end
