function e = saw( frac, numcycles, mn, mx, start, upwards )
    if numcycles==0
        e = start*ones(size(frac));
        return;
    end
    if start < mn
        mn = start;
    end
    if start > mx
        mx = start;
    end
    frac_y = (start-mn)/(mx-mn);
    frac_y = decompressfrac( frac_y );
    if upwards
        start_x = frac_y/2;
    else
        start_x = 1 - frac_y/2;
    end
    x = start_x + frac*numcycles;
    x = 2*(x - floor(x));
    x(x > 1) = 2 - x(x > 1);
    x = compressfrac( x );
%{
    initfrac = 1 - (start-mn)/(2*(mx-mn));
    frac = frac*numcycles + initfrac;
    frac = frac - floor(frac);
    frac(frac>0.5) = 1 - frac(frac>0.5);
  % frac = frac*2;
  % frac = compressfrac( frac );
%}
    e = mn + x*(mx-mn);
end

function d = decompressfrac( f )
    d = acos( 1 - 2*f )/pi;
end

function c = compressfrac( f )
    if 1
        c = (1-cos(f*pi))/2;
    elseif 0
        c = ((f-0.5)^2)*2;
        if f < 0.5
            c = -c;
        end
        c = 0.5+c;
    else
        sharpness = 0.3;
        c = 0.5 + asin(2*(f-0.5)*sharpness)/(2*asin(sharpness));
    end
end
