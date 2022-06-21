function state_incs = state_incs(X, obs_cen, obs_prior_var, obs_incs)

if obs_prior_var <= 0
    state_incs = 0 * X;
    return
end

nrens         = length(X);

sta_cen       = X - sum(X)/nrens; 

obs_state_cov = sum( sta_cen .* obs_cen )/( nrens-1 );  

state_incs    = obs_incs * obs_state_cov / obs_prior_var;
