function m = upgradeCallbacks( m )
%m = upgradeCallbacks( m )
%   Upgrade a mesh to use the new-style user callbacks.
%   If you currently use any old-style callbacks, before you call this
%   function you must edit your interaction function to rename them
%   according to the new style, and to remove all of the calls to
%   leaf_setproperty that installed the old-style callbacks.  Then,
%   load your project, export the initial mesh, call this function on
%   EXTERNMESH, and then import the mesh.

    if m.globalProps.newcallbacks
        return;
    end
    m.globalProps.newcallbacks = true;
    saveStaticPart( m );
    rewriteInteractionSkeleton( m, [], [], mfilename() );
end
