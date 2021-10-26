function result = userHomeDirectory()
    if ispc
        result = getenv('USERPROFILE'); 
    else
        % Assuming Unix-like environment, i.e. Unix, Linux, OSX.
        result = getenv('HOME');
    end
end
