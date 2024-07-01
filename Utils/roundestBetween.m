function v = roundestBetween( v0, v1 )
    if (v0 <= 0) && (v1 >= 0)
        v = 0;
    else
        s = sign(v1);
            minv = min(v0,v1);
            maxv = max(v0,v1);
        if s==-1
            v0 = -maxv;
            v1 = -minv;
        else
            v0 = minv;
            v1 = maxv;
        end
        n = ceil(log10(v1));
        tn = 10^n;
        v0 = v0 / tn;
        v1 = v1 / tn;
        while (ceil(v0 - 10*eps(v0)) > floor(v1 + 10*eps(v1))) && (n > -100)
            v0 = v0*10;
            v1 = v1*10;
            n = n-1;
        end
        v = ceil(v0 - 10*eps(v0)) * s * 10^n;
        xxxx = 1;
    end
end

