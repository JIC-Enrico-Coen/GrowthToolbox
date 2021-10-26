function [ok,e] = canUseGPUArray()
    try
        x = gpuDevice();
        cc = sscanf( x.ComputeCapability, '%f' );
        ok = cc >= 1.3;
        e = '';
    catch e
        ok = false;
    end
end
