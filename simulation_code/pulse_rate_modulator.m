function [firing sim_info] = pulse_rate_modulator(sim_info,mod_function,curr_options, change_params, tot_reps, output,override)
%Pulse rate modulation code
%Takes in a function and modulates pulse rate with shape of function
%https://pubmed.ncbi.nlm.nih.gov/21859631/ - every 10 ms change sampling of
%function: .5  to 10 Hz sinuosoid.
%Started 12/27/20 CRS
%Last Updated 12/27/20 CRS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
plot_steps = 0; %plot graphs to check along the way
dt = 1e-6; %s
sim_time = round(2+sim_info.sim_start_time*1e-3); %s
sim_info.sim_time = sim_time/1e-3;
pulse_height = 10;%curr_options;

Fs= 10000;% Hz - every .1 ms
dt_mod  = 1/Fs; %s

if isempty(mod_function)
    t_full = 0:dt:sim_time-dt; %s
    mean_val = 60;
    scale = [1 5.5];%[1 5.5]; %neg, pos
    mod_freq = 2; %Hz
    delay = 500; %ms
    
    mod_function = sin(mod_freq*2*pi*t_full);
    timing = [zeros(1,.5*delay*1e3) -ones(1,.5*delay*1e3) mod_function([1:(1e3*(sim_time*1e3-delay))])];
    mod_function(mod_function > 0)= mod_function(mod_function > 0)*mean_val*scale(2);
    mod_function(mod_function < 0)= mod_function(mod_function < 0)*mean_val*scale(1);
    mod_function = [zeros(1,.5*delay*1e3) -mean_val*ones(1,.5*delay*1e3) mod_function([1:(1e3*(sim_time*1e3-delay))])];
    mod_function = mod_function+ mean_val;
    firing.delay = delay;
    firing.mod_f = mod_function;
    firing.mod_timing = timing;
end

update_freq= 5*1e-3;%s%10*1e-3;%s

smple_freq = update_freq/dt;
[p_times]  = mod_f_t_pr(mod_function,smple_freq,t_full,dt, plot_steps);


%Make Pulse over Time
stim_interv = 150;%uS (from Mitchell)
pulse_times = round(p_times+delay+sim_info.sim_start_time*1e3);
pulse_times = pulse_times(pulse_times < sim_time*1e6);

I_st = zeros(1,sim_time/dt);
for n_ps = 1:length(pulse_times)
    I_st([round([pulse_times(n_ps):pulse_times(n_ps)+stim_interv-1])]) = pulse_height;
    I_st([round([(pulse_times(n_ps)+stim_interv):(pulse_times(n_ps)+2*stim_interv-1)])]) = -pulse_height;
end
if plot_steps
    figure(2); plot(dt*(1:length(I_st)),I_st); xlabel('Time (s)'); ylabel('I_{inj}');
end

%Variables for Simulation
idx_minus = I_st < 0;idx_plus = I_st > 0;
change_params.I_st = I_st;
change_params.I_st(idx_plus) = curr_options;
change_params.I_st(idx_minus) = -curr_options;
change_params.Inj_cur = curr_options;
sim_info.isPlan =1 ;
for rep_num = 1:tot_reps
    %%%   rng(rep_num); - if want to try setting seed and comparing
    [spiking_info] =  run_expt_on_axon_10_10_20_f(sim_info,output,change_params)
    firing.rep(rep_num).times = spiking_info.end.spk_times;
end
firing.rep(rep_num).pulse_times = pulse_times;
firing.mod_freq= mod_freq;

end


function [p_times] = mod_f_t_pr(mod_function,smple_freq,t,dt, plot_steps)
t_mod_smple = 1:(smple_freq):length(t);
t_lst_pulse = 0;
p_times = [1];
for cur_t = 1:(length(t_mod_smple)-1)
    %At this time what is the new pulse rate
    cur_pr = mod_function(t_mod_smple(cur_t));
    if isinf(cur_pr)
        cur_ipi = 1e10;
    else
    cur_ipi = round((1/cur_pr)/dt); %s - dt adjust
    end
    
    %Case when there has been a time where there has been no pulses in a
    %very long time:
    if  (t_mod_smple(cur_t) - t_lst_pulse) > 80e3
        t_lst_pulse = t_mod_smple(cur_t);
        if cur_pr > 0
         p_times = [p_times t_lst_pulse];    
        end
    end
    
    %Give pulses at current frequency until next sample
    %Finds last pulse in sequence
    if cur_ipi < smple_freq
        next_p_times = t_lst_pulse:cur_ipi:t_lst_pulse+smple_freq;
        next_p_times(next_p_times == t_lst_pulse) = [];
        t_lst_pulse = round(next_p_times(end));
        p_times = [p_times round(next_p_times)];
        
    else
        pred_next_p_time = t_lst_pulse + cur_ipi;
        %In time window?
        is_new_pulse = (pred_next_p_time >= t(t_mod_smple(cur_t))/dt) ...
            & (pred_next_p_time < (t(t_mod_smple(min(length(t_mod_smple),cur_t+1)))/dt));
        is_missed_pulse = (pred_next_p_time < t(t_mod_smple(cur_t))/dt); % when next sample it's a little bit short of range
        if (is_new_pulse | is_missed_pulse)
            p_times = [p_times round(pred_next_p_time)];
            t_lst_pulse = round(pred_next_p_time);
            pred_next_p_time = [];
        end
    end
end

if plot_steps
    figure(1); ax1= subplot(2,1,1);
    plot(1e3*t,mod_function,'.'); hold on;
    plot(1e3*t(t_mod_smple),mod_function(t_mod_smple),'o'); box off;
    title('Modulation function'); ylabel('Pulse Rate (pps)')
    ax2=subplot(2,1,2);
    plot(1e3*p_times*dt,ones(size(p_times)),'.','markersize',10); hold on; box off;
    plot(1e3*t(t_mod_smple), ones(size(t_mod_smple)),'.');
    xlabel('Time (ms)'); ylabel('Pulse Timing')
    linkaxes([ax1 ax2 ],'x')
end
end
%%