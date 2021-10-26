function v = sigmoid( x, midx, minv, maxv, width, type )
    x = (x-midx)/width;
    switch type
        case 'atan'
            v = atan(x)*(2/pi)+0.5;
        case 'logistic'
            v = 1./(1 + exp( -x ));
    end
    v = minv + (maxv-minv)*v;
end
