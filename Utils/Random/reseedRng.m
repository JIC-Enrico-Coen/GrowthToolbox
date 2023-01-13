function seednumber = reseedRng( data )
%seednumber = reseedRng( data )
%   Reseed the Twister random number generator.
%
%   With no arguments it will use the clock time as a source of
%   non-deterministic data to make a seed from.
%
%   If DATA is 'uuid', a uuid will be generated (by
%   matlab.lang.internal.uuid()) and converted into a number to be combined
%   with the clock time to make the seed.
%
%   If DATA is a numeric array, its elements will be summed and combined
%   with the clock time to make the seed.
%
%   The resulting seed is returned.

    c = clock();
    seednumber = sum(c(1:5)) + c(6)*1e6;
    if nargin > 0
        if strcmp( data, 'uuid' )
            uuidchars = uint64( char( matlab.lang.internal.uuid() ) );
            n = length(uuidchars) - mod( length(uuidchars), 4 );
            uuidchars = reshape( uuidchars(1:n), [], 4 );
            data = (uint64(2^24) * uuidchars(:,1)) + (uint64(2^16) * uuidchars(:,2)) + (uint64(2^8) * uuidchars(:,3)) + uuidchars(:,4);
        end
        seednumber = seednumber + sum(double(data(:)));
    end
    seednumber = uint32( mod( seednumber, 2^32 ) );
    fprintf( 'Seed supplied: %d\n', seednumber );
    rng(seednumber,'twister');
end

