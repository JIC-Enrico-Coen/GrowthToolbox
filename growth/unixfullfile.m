function fullname = unixfullfile( varargin )
%fullname = unixfullfile( varargin )
%   Like the Matlab function fullfile, but specific to *nix and Mac
%   systems. This is needed when constructing file paths for a remote
%   machine that is not running Wiondows.
%
%   Note that for this scenario, there cannot be a similar version of
%   fullpath, because there is no notion of the "current directory" when
%   referring to a remote machine.
%
%   See also: fullfile

    nonempty = true( 1, nargin );
    for i=1:nargin
        nonempty(i) = ~isempty(varargin{i});
    end
    varargin = varargin( nonempty );

    joined = join( varargin, '/' );
    fullname = joined{1};
end
