function v = safestructaccess( s, f, default )
    if isfield( s, f )
        v = s.(f);
    else
        v = defaults;
    end
end
