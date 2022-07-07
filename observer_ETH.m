function [H, ObsLoc, Observations, obs_err_var, da] = observer_ETH(Nx, da, sig_2, Active, Recovered, Deaths, Vaccinated)

    switch da.data_type
        case 'ARDV'
            da.vars = 4:Nx;
 
            hdiag          = zeros(Nx, 1);
            hdiag(da.vars) = 1;
            izeros         = ~hdiag;
            H              = diag(hdiag);
            H(izeros, :)   = [];

            obs_err_var  = diag(sig_2(da.vars));
            Observations = [Active; Recovered; Deaths; Vaccinated];

        case 'AR'
            da.vars = 4:5;

            hdiag          = zeros(Nx, 1);
            hdiag(da.vars) = 1;
            izeros         = ~hdiag ;
            H              = diag(hdiag);
            H(izeros, :)   = [];

            obs_err_var  = diag(sig_2(da.vars));
            Observations = [Active; Recovered];
    
        case 'AD'
            da.vars = 6:Nx;

            hdiag          = zeros(Nx, 1);
            hdiag(da.vars) = 1;
            izeros         = ~hdiag ;
            H              = diag(hdiag);
            H(izeros, :)   = [];

            obs_err_var  = diag(sig_2(da.vars));
            Observations = [Active; Deaths; ];
         
    end

    ObsLoc = find(hdiag>0); 
end
