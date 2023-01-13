function fullfilepath = makerootpath( filepath )
    if isrootpath( filepath )
        fullfilepath = filepath;
        return;
    end
    fullfilepath = fullfile( pwd(), filepath );
end
        