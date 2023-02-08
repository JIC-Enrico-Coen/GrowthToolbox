function mycaxis( pic, crange )
%mycaxis( pic, crange )
%   This ensures that crange(2) > crange(1), and then calls clim (if it
%   exists), otherwise caxis (deprecated in Matlab 2022a onwards).

    if crange(2) <= crange(1)
        crange = [0 1];
    end
    if exist('clim','file')
        clim( pic, crange )
    else
        caxis( pic, crange );
    end
end