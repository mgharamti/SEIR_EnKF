function X1 = seir_rk4(model, X0)

    dt = model.dt;
    Cy = model.Np - 1;

    for t = 1:Cy
        K1 = seir_eqns(model, X0            );
        K2 = seir_eqns(model, X0 + 0.5*dt*K1);
        K3 = seir_eqns(model, X0 + 0.5*dt*K2);
        K4 = seir_eqns(model, X0 + 1.0*dt*K3);
    
        X0 = X0 + dt * (K1 + 2*K2 + 2*K3 + K4) / 6;
    end

    X1 = X0;
end
