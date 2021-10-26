function img = changeHues( img, oldhues, newhues, tol )
%img = changeHues( img )
%   

    if nargin < 4
        tol = 0;
    end
    imghsv = rgb2hsv(img);
    numhues = length( oldhues );
    huemaps = false( size(img,1), size(img,2), numhues );
    imghue = imghas(:,:,1);
    for i=1:numhues
        huemaps(:,:,i) = abs( imghue - oldhues(i) ) < tol;
    end
    for i=1:numhues
        imghue(huemaps(:,:,i)) = newhues(i);
    end
    imghsv(:,:,1) = imghue;
    img = hsv2rgv(imghsv);
end
