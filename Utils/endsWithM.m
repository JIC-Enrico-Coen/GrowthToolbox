function result = endsWithM( s1, s2 )
%result = endsWithM( s1, s2 )    Returns 1 if the string s1 ends with the
%string s2, 0 otherwise.
%This is called endsWithM to avoid a clash with a java function present
%in some systems called endsWith.

    b = length(s1);
    a = b - length(s2) + 1;
    if a <= 0
        result = 0;
        return;
    end
    result = strcmp( s1( a:b ), s2 );
end
