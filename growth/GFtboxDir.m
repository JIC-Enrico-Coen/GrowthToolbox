function dirname = GFtboxDir()
%dirname = GFtboxDir()
%   Find the Growth Toolbox directory.

    gftboxFile = which('GFtbox');
    if isempty(gftboxFile)
        dirname = '';
    else
        dirname = fileparts(gftboxFile);
    end
end
