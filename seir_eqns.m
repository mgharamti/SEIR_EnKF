function fX = seir_eqns(model, X)

    % State: X = [S, E, I, Q, R, D, V]
    % where, X(1) = S,
    %        X(2) = E,
    %        X(3) = I, 
    %        X(4) = Q, 
    %        X(5) = R, 
    %        X(6) = D, 
    %        X(7) = V.

    fX = zeros(model.Nx, 1);

    % Parse model parameters:
    Lambda = model.Lambda;
    alpha  = model.alpha;
    beta   = model.beta;
    sigma  = model.sigma;
    kappa  = model.kappa;
    mu     = model.mu;
    gamma  = 1 / model.tinc;
    delta  = 1 / model.tinf;
    lambda = 1 / model.trec;
    rho    = 1 / model.tdea;
%     beta   = model.Rp * delta / model.Npop;

    % Set fX(1).
    fX(1) = Lambda - beta * X(1)*X(3) - alpha * X(1) - mu * X(1);

    % Set fX(2).
    fX(2) = beta * X(1)*X(3) - gamma * X(2) + sigma * beta * X(7)*X(3) - mu * X(2);

    % Set fX(3).
    fX(3) = gamma * X(2) - delta * X(3) - mu * X(3);

    % Set fX(4).
    fX(4) = delta * X(3) - (1 - kappa) * lambda * X(4) - kappa * rho * X(4) - mu * X(4);

    % Set fX(5).
    fX(5) = (1 - kappa) * lambda * X(4) - mu * X(5);

    % Set fX(6).
    fX(6) = kappa * rho * X(4);

    % Set fX(7).
    fX(7) = alpha * X(1) - sigma * beta * X(7)*X(3) - mu * X(7);
    
end
