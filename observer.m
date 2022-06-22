function [H, ObsLoc, Observations, obs_err_var] = observer(Nx, cas, sig_2, Active, Recovered, Deaths, Vaccinated)

    switch cas
        case 'ARDV'
            vars = 4:Nx;

            hdiag        = zeros(Nx, 1);
            hdiag(vars)  = 1;
            izeros       = ~hdiag;
            H            = diag(hdiag);
            H(izeros, :) = [];

            obs_err_var  = diag(sig_2(vars));
            Observations = [Active; Recovered; Deaths; Vaccinated];
    
        case 'DV'
            vars = 6:Nx;

            hdiag        = zeros(Nx, 1);
            hdiag(vars)  = 1;
            izeros       = ~hdiag ;
            H            = diag(hdiag);
            H(izeros, :) = [];

            obs_err_var  = diag(sig_2(vars));
            Observations = [Deaths; Vaccinated];

         case 'D'
            vars = 6;

            hdiag        = zeros(Nx, 1);
            hdiag(vars)  = 1;
            izeros       = ~hdiag ;
            H            = diag(hdiag);
            H(izeros, :) = [];

            obs_err_var  = diag(sig_2(vars));
            Observations = Deaths;
    end

    ObsLoc = find(hdiag>0); 
end
