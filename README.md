# SEIR EnKF

The following repo implements the extended SEIR model presented in Ghostine et al. (2021) *"An Extended SEIR Model with Vaccination for Forecasting the
COVID-19 Pandemic in Saudi Arabia Using an Ensemble Kalman Filter."*

The model consists of seven state variables,
- Susceptible (S)
- Exposed (P)
- Infected (I)
- Quarantined (Q)
- Recovered (R)
- Deaths (D)
- Vaccinated (V)

and few other parameters including: 
- $\Lambda$: New births and new residents per unit of time,
- $\beta$: Transmission rate divided by the population size $N$,
- $\alpha$: Vaccination rate,  
- $\mu$: Natural death rate,
- $\gamma$: Average latent time, 
- $\delta$: Average quarantine time, 
- $\kappa$: Mortality rate, 
- $\lambda$: Average days until recovery, 
- $\rho$: Average days until death,
- $\sigma$: Vaccine efficiency ($0\leq \sigma \leq 1$).

The SEIR model uses a 4th order Runge-Kutta numerical solver. An ensemble data assimilation (DA) system is coupled to the model in which observations such as active, recovered, deaths and vaccinated cases can be assimilated to improve the accuracy of the model. The DA system supports 3 filtering options: 
- (Stochastic) Ensemble Kalman Filter - *EnKF*
- Ensemble Adjustment Kalman Filter - *EAKF*
- Rank Histogram Filter - *RHF*

Other implemented DA algorithms include **multiplicative inflation**, **additive inflation** and **anamorphosis (i.e., state transformation)**. 
