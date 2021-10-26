function result = is_function_handle( h )
    result = strcmp( class(h), 'function_handle' );
end
