function [output] = run_chosen_expt(expt,run_mode,override,output)
%Run from vestib_afferent_model_pulsatile_main.m
%expt - which experiment to run
%run_mode - know whether to run or exactly or overridden
%override - what replaces sim_info
%7/1/21 - add output variable for any desired outputs for call function
%Started 12/27/20
%Last Updated 12/27/20

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
output = [];
if strcmp(run_mode,'exact')
    %%%%%BASIC SIMULATION SETTINGS
    if isempty(expt.num) | ismember(expt.num,[5])
        tot_reps = 1;
    else
        tot_reps = 10;
    end
    
    if (isempty(expt.num))
        output.vis_plots = 1;
    else
        output.vis_plots = 0;
    end
    sim_info.sim_time = 1050; %ms Simulation length
    sim_info.sim_start_time = 150; %start stimulate part of experiment (usually 1 ms)
    sim_info.sim_end_time = [];
    sim_info.dt = 1e3; %1/1000 of a ms
    sim_info.inj_cur = [1 1];%Allow posibility of (1) injected current and (2) epsp release
    sim_info.isPlan = 0;
    sim_info.isDC = 0;
    sim_info.low_cond = [0]; % Axon is low cond like Manca expt or high cond like Goldberg
    %Can manipulate here to try diff scenarios. If empty - chooses by what expt
    %was performed on
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%NEURON SPECIFIC SETTINGS
    %For incorportating adaptation function: (DC)
    sim_info.do_adapt = 0; %do an adaptation in mu at all (for DC)
    sim_info.do_orig = 0; %do it in the original adaptation way of the paper v. the modified way
    
    %%%Adaptation function settings:
    sim_info.g_o_1 = 3.25*.15; %low cond model
    sim_info.g_o_2 = 3.25*.9;
    % What the taus should be?
    sim_info.tau_1 = 2;%Manca 2.26, final 2
    sim_info.tau_2 = .3;%Manca 0.24, final .3
    sim_info.sense_scale =  0;%0.25;
    sim_info.fr_o = 45;
    
    sim_info.is_reg = 0;
    sim_info.doIh = 0; %hyperpolarization-activated cationic current
    %Simulation parameters generically
    sim_info.epsc_sample= .1;
    sim_info.epsc_over_ride = 0;%choose exact EPSC timing/height ( for tref experiment)
    
    %%%%%%%%%%%%%%%%%%% Neuron type -conductance, K, mu settings for an  irregular
    range_scale = 1;
    if ~sim_info.is_reg
        %Irregular:
        sim_info.mu_IPT = 2;%3.5;%.8;
    else
        %Regular
        sim_info.mu_IPT = 3.5;
    end
    
    %%%set sensitivity and adaptation measures
    sim_info.scale_adapt_mu = 0;
    
    %     %Model from DC paper
    %     gNas = .6*13;
    %     gKHs = 4*2.8;
    %MODEL from last EMBC paper
    gNas = range_scale*13;%6*13 (these are for normal axon model). The used are for mitchell (lower firing model)
    gKHs = range_scale*2.8;%4*2.8;
    
    if ~sim_info.is_reg
        %Irregular
        gKLs = 1;%.75;
    else
        %Regular
        gKLs = 0;%.75;
    end
else
     sim_info = override.sim_info;
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%% Running the simulations!
%%%% Run and show the output with a pulse rate or current amplitude to
%%%% visualize
%%Experiment specific settings below
%THE NAMES OF EXPERIMENTS NUMBERED
expt_name = {'pulse_adapt_gen','pulse_adapt_best_mitchell',...
    'pulse_fr_gen','pulse_fr_best_mitchell','prm'};

%%%%% Basic Experimental Set Up - pulse rate, current amplitudes
if isempty(expt.num)
    %Run a demo - with output.vis_plots = 1; to see axonal and channel
    %responses
    
    if ~sim_info.inj_cur(1)
        %Just an axon
        curr_options = 0;
        pulse_rate = 0; %all expts are empty
        
    else
        if sim_info.isDC
            %Some level of DC with hair cell adaptation as in DC paper
            sim_info.non_quant = 2.5;
            sim_info.do_adapt = 1;
            sim_info.do_orig= 0;
            curr_options = -.020;
            pulse_rate = 0;
        else
            %Basic Pulsatile Stimulation experiment (DEMO)
            curr_options = -[2];%For pulsatile!
            pulse_rate = [100];
        end
    end
    
end

sim_info.isDC = 0;
%Only pulsatile experiments
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%Pulse Adapt/firing rate Experiments
if ismember(expt.num,[1:4])
    tot_reps = sim_info.tot_reps;
    pulse_rate =[0 25 50 75 100 175 200 300]; % pulses per second (from A)
    
    %Closest match to Mitchell et al paper results
    if ismember(expt.num,[2 4])
        best_mitch_res = 1; % sub experiment of pulse_fr
    else
        best_mitch_res = 0;
    end
    
    if best_mitch_res
        curr_options = -11.52;% (found by optimization)
    else
        curr_options = 1e-3*linspace(-18000,0,25);
        % To search and optimize pulsatile currents amplitude
    end
    
    if ismember(expt.num,[1 2]) %pulse_adapt
        
        sim_info.isPlan = 1; % set pulse blocks over time
    else
        tot_reps = 10;
        sim_info.isPlan = 0;
    end
    
    %Set up output structure
    avg_ISI = zeros(tot_reps,length(pulse_rate));
    avg_CV = zeros(tot_reps,length(pulse_rate));
    if sim_info.isPlan
        fr = zeros(tot_reps,length(curr_options));
    else
        fr = zeros(length(curr_options),length(pulse_rate),tot_reps);
    end
    
else
    if expt.num == 5
        sim_info.isPlan = 1;
    else
        sim_info.isPlan = 0;
    end
end

if strcmp(run_mode,'override')
    %The things that can be overridden for use in experiments below
    gNas = override.gNas;
    gKHs = override.gKHs;
    gKLs = override.gKLs;
    sim_info = override.sim_info;
    tot_reps = override.sim_info.tot_reps;
    pulse_rate = override.pulse_rate;
    curr_options = override.curr_options;
    output = override.output;
end

change_params.neuron.gNa = gNas;
change_params.neuron.gKL = gKLs;
change_params.neuron.gKH = gKHs;

%% Individual runs with certain current amplitude pulsatile experiments
%To test response across many pulse rates and current amplitudes run
%with parfor
%tic
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isempty(expt.num)
    %Visualize a bunch of results including channels and specific spike
    %timing
    if output.label_aps
        rng(1); % set see to be able to view APs
    end
   
    %output.vis_plot = 1;%plot #
    output.pp_plot = 20;%phase plane analysis
    do_parallel = 0; % for observing individual trace responses
    [spiking_info,fr, avg_CV, avg_ISI] = pulse_adapt_expt_indiv(sim_info,curr_options, pulse_rate, output, change_params, tot_reps,do_parallel,expt,[]);

    plot_CV_ISI = 0;
    if plot_CV_ISI
        figure(4); loglog(avg_ISI(2:end),avg_CV(2:end),'g^'); hold on;
        plot(avg_ISI(1),avg_CV(1),'gx','markersize',15);
        ylim([0.03 1]); xlim([0 35]); box off;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Plot Firing Rate Over Time
    plot_t_fr = 0;% giving moving average output
    if plot_t_fr
        figure(5);
    [rel_times] = moving_avg_fr(sim_info, spiking_info.end.spk_times,50,2);
    end
    output.fr= fr;
    output.CV = avg_CV;
    output.ISI = avg_ISI;
    output.spiking = spiking_info;
end


%%%%%%%%%%%%%%%%%% Pulse adaptation full experiment (with/without Mitchell
%%%%%%%%%%%%%%%%%% settings). If not mitchell need one current amplitude
if ismember(expt.num,[1 2])
    tot_reps = 1;%%% TESTING
    output.vis_plot= 2; % fig # where plot is (if want to visualize whole traces of V,I, etc.)
    [firing block_ts curr_amps run_full] = pulse_adapt_expt(sim_info,pulse_rate,curr_options, change_params, tot_reps, output);
    
end


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Running many current amplitudes and pulse rates:
%Make data to check model against:
if ismember(expt.num,[3 4])
    rng(2)
    do_parallel = 1; % fast run and save out data
    if do_parallel 
        output.vis_plots = 0; 
    end
    
    gNs = [gNas, gKLs, gKHs];
    tic
    [spiking_info,fr, avg_CV, avg_ISI] = pulse_adapt_expt_indiv(sim_info,curr_options, pulse_rate, output,change_params, tot_reps,do_parallel,expt, gNs);
    toc
    
    % save_out = 0;
    % 
    % if save_out
    % 
    %     save(sprintf('pr_fr_sim_rep%s_I%s-%s_PR%s-%s_S%s_reg%s_sim_wind%s_%s.mat',num2str(tot_reps),num2str(max(curr_options)*-20),num2str(min(curr_options)*-20),...
    %         num2str(min(pulse_rate)),num2str(max(pulse_rate)),num2str(mean(fr(:,1))),num2str(sim_info.is_reg),num2str(sim_info.sim_time),datestr(now,'mm_dd_yyyy_HH_MM')),...
    %         'fr','avg_CV','avg_ISI','sim_info','expt','curr_options','pulse_rate')
    %     cd(cur_dir)
    % 
    % end
   
end


%%%%%%%%%%%PULSE MODULATION EXPERIMENTS Rate/amplitude
if ismember(expt.num,[5])
    
    %If is [] then will build a mod function in the pulse_modulator function
    %   mod_function  = override.firing.mod_f;
    plot_it = 1;
    bin_hlf_wdth = 30;
    if override.rate_mode % Modulating Amplitude (0) Rate = (1)
        curr_options = override.firing.pa_base/-20;
        %Set around the input current (for testing likely 150 uA (midrange one bend)
        %linspace(80,250,10)/-20;%[20 90 100 110 120 150 200 225]/-20; %-10;
        
        [firing sim_info] = pulse_modulator(sim_info,override.firing,curr_options, change_params, tot_reps, output,override.rate_mode)
        %Plot Firing Rate Over Time
    else
        mod_function  = override.firing;
        
        [firing sim_info] = pulse_modulator(sim_info,mod_function,curr_options(1), change_params, tot_reps, output,override.rate_mode)
    end
    
    [fr_per_bin bin_times] = moving_avg_fr(sim_info,  firing.rep.times, bin_hlf_wdth, []);
    base_fr = mean(fr_per_bin(1:9));
    
    [pulse_per_bin bin_times] = moving_avg_fr(sim_info,  firing.rep.pulse_times*1e-3, bin_hlf_wdth,[]);
    
    offset = firing.delay + sim_info.sim_start_time;
    [a use_idx]=min(abs(bin_times - offset));
    use_bins = [use_idx:length(pulse_per_bin)];
    if plot_it
        if override.rate_mode
            figure(100);
        else
            figure(101);
        end
        ax1= subplot(3,1,1);plot(firing.mod_timing(round(bin_times(use_bins)*1e3))*1e3,...
            firing.mod_f(round(bin_times(use_bins)*1e3)),'k.--'); hold on; ylabel('Head Velocity');
        xlim([0 sim_info.sim_time]); %ylim([0 300])
        ax2=subplot(3,1,2:3);
        
        plot(bin_times(use_bins),pulse_per_bin(use_bins),'r'); hold on;
        xlabel('Time (ms)'); ylabel('Pulse Rate (sps)')
        xlim([0 sim_info.sim_time]); hold on; ylim([0 300])
        % subplot(3,1,3);
        plot(bin_times(use_bins),fr_per_bin(use_bins),'b'); hold on;
        xlabel('Time (ms)'); ylabel('Firing Rate (sps)')
        xlim([0 sim_info.sim_time]); hold on; ylim([0 300])
        legend('pr','fr')
        if override.rate_mode
            title(sprintf('PRM %s pps [+- %s]',num2str(override.firing.pm_base),num2str(override.firing.pm_mod_amp)))
        else
            
            title(sprintf('PAM %s uA [+- %s]',num2str(-20*curr_options),num2str(override.firing.pm_mod_amp)))
            
        end
        linkaxes([ax1 ax2],'x')
    end
    
    pr_vect =pulse_per_bin(use_bins);
    fr_vect = fr_per_bin(use_bins);
    time_vect = bin_times(use_bins);
    mod_vect = firing.mod_f(round(bin_times(use_bins)*1e3));
    
    %Error  comparisions:
    [corr_val p_val]=corr((pr_vect)', fr_vect');
    [corr_val_modf p_val]=corr((mod_vect)', fr_vect');
    sim_pm.corr_pr = corr_val;
    sim_pm.corr_mdf = corr_val_modf;
    sim_pm.pval = p_val;
    if override.rate_mode
        sim_pm.mode= 'prm';
    else
        sim_pm.mode= 'pam';
    end
    sim_pm.fr_vect = fr_vect;
    sim_pm.pr_vect = pr_vect;
    sim_pm.mod_vect = mod_vect;
    sim_pm.t_vect = time_vect;
    sim_pm.override =override;
    disp([ sim_pm.mode ' , corr = ', num2str(sim_pm.corr_mdf)] );
    output = sim_pm;
end
%toc


if ismember(expt.num,[6])
    rng(2)
    do_parallel = 1; % fast run and save out data
    if do_parallel 
        output.vis_plot = 0; 
    end
    
    gNs = [gNas, gKLs, gKHs];
    tic
    [spiking_info,fr, avg_CV, avg_ISI] = pulse_adapt_expt_indiv(sim_info,curr_options, pulse_rate, output,change_params, tot_reps,do_parallel,expt, gNs);
    toc
    
    %Check pa-fr
    if length(curr_options) > length(pulse_rate)
    figure(10);
    shadedErrorBar(curr_options*-20,squeeze(mean(fr,3)),squeeze(std(fr,[],3)));
    xlabel('uA'); ylabel('sps');
    title(['PAM result, PR = ' num2str(pulse_rate)]);
    else
    figure(10);
    shadedErrorBar(pulse_rate,squeeze(mean(fr,3)),squeeze(std(fr,[],3)));
     xlabel('pps'); ylabel('sps');
     title(['PRM result, PA = ' num2str(curr_options*-20)]);
    end
   
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%% Plotting Results
%% Pulsatile adaptation experiment  (From Mitchell)
color_cs = spring(max(length(curr_options),5));
if ismember(expt.num,[1 2]) %%pulse_adapt
    if run_full
    clear spk_per_bin spk_per_z
    figure(8);
    for n_cs = 1:length(curr_options)
        subplot(2,1,1);
        for n_reps = 1:length(firing(1).rep)
            for n_pulse_trials = 2:2:length(block_ts)
                spk_per_bin(n_cs,n_reps,n_pulse_trials/2) = sum((firing(n_cs).rep(n_reps).times < block_ts(n_pulse_trials)/1e3) &  ...
                    (firing(n_cs).rep(n_reps).times >  block_ts(n_pulse_trials-1)/1e3))/((block_ts(n_pulse_trials)-block_ts(n_pulse_trials-1))/1e6);
                plot([block_ts(n_pulse_trials-1) block_ts(n_pulse_trials)]/1e6,...
                    .5*ones(size([block_ts(n_pulse_trials-1) block_ts(n_pulse_trials)]/1e6)),'r-','linewidth',3); hold on;
            end
        end
        
        subplot(2,1,2);
        [shuff_p p_ord] = sort(pulse_rate);
        errorbar(pulse_rate(p_ord), mean([ squeeze(spk_per_bin(n_cs,:,p_ord))],1),...
            std([ squeeze(spk_per_bin(n_cs,:,p_ord))],[],1),'color',color_cs(n_cs,:,:));
        hold on;
        xlabel('pulse rate (pps)'); ylabel('firing rate (sps)')
        plot(5*n_cs,0,'*','color',color_cs(n_cs,:,:)); pause(0.3);
    end
    else
        mitchell_res = [45 50 58 70 78 85 103 112];
        for n_blcks = 1:length(curr_amps.diff_blck_prs)
        before_fr = squeeze(curr_amps.diff_blck_prs(n_blcks).spk_per_bin(:,1,1));
        after_fr = squeeze(curr_amps.diff_blck_prs(n_blcks).spk_per_bin(:,1,3));
        
        figure(10); 
        subplot(length(curr_amps.diff_blck_prs)+1,1, n_blcks);
        plot(pulse_rate,before_fr,'b'); hold on;
        plot(pulse_rate,after_fr,'r'); xlabel('Pulse Rate (pps)'); ylabel('Firing Rate (sps');
        plot(pulse_rate,mitchell_res,'k','linewidth',2);
        title(sprintf('%s uA',num2str(curr_amps.blck_cur(n_blcks))));
           ylim([0 180])
        subplot(length(curr_amps.diff_blck_prs)+1,1, length(curr_amps.diff_blck_prs) +1 );
     
        errorbar(n_blcks,mean(curr_amps.diff_blck_prs(n_blcks).spk_per_bin(:,1,2)),...
            std(curr_amps.diff_blck_prs(n_blcks).spk_per_bin(:,1,2)),'k.'); hold on;
        bar(n_blcks,mean(squeeze(curr_amps.diff_blck_prs(n_blcks).spk_per_bin(:,1,2))));
           ylim([0 180]); ylabel('Firing Rate (sps)')
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PULSE FIRING RATE RELATION (Diff amplitudes)
if ismember(expt.num,[3 4]) %pulse_fr
    
    S = fr(find(curr_options == 0));
    [shuff_p p_ord] = sort(pulse_rate);
    if  ismember(expt.num,[3]) %%~best_mitch_res
        %Satellite plot of fr v. pr for each amplitude
        for n_amp = 1:length(curr_options)
            subplot(ceil(sqrt(length(curr_options))),ceil(sqrt(length(curr_options))),n_amp);
            hold on;
            errorbar(pulse_rate,mean(fr(:,n_amp,:),3),std(fr(:,n_amp,:),[],3),'k'); hold on;
            xlabel('Pulse Rate (pps)'); ylabel('Firing Rate (sps)')
            title(num2str(curr_options(n_amp)*-20))
        end
        
    else
        %% MITCHELL RESULTS COMPARISON (expt.num = [4])
        best_tref = .0065; %where peaks
        t_ref = 1e-3*[1:2000];
        S = 45;
        R = pulse_rate;
        
        t_ref_norm = .004;%9*1e-3; %How high
        fr_from_pulse = R./(ceil(best_tref'./(1./R)));
        pred_frs = fr_from_pulse*(1-S*t_ref_norm) + ... % *(1-S.*t_ref_norm)
            S*(1-(fr_from_pulse*best_tref'));
        
        %Find the closest to mitchell results:
        mitchell_res = [45 50 58 70 78 85 103 112];
        figure(5); plot(pulse_rate,mean(fr(1,:,:),3)','.--');  hold on;
        plot([0 25 50 75 100 175 200 300],mitchell_res,'k');
        plot(R,pred_frs,'g')
        
        [rms_e which_current] =  min(rms(mean(fr,3) - mitchell_res,2));
        [mean(rms(fr(which_current,:,:) - mitchell_res)) std(rms(fr(which_current,:,:) - mitchell_res))]
        curr_options(which_current)
        %If best_mitchell then just going to be one line
        figure(11); real= plot(pulse_rate,mitchell_res,'k.-'); hold on;
        if size(size(fr),2) == 2
            plot(pulse_rate(p_ord),fr(:,p_ord),'b');
        else
            pred = errorbar(pulse_rate(p_ord)', mean(squeeze(fr(:,p_ord,:)),2),...
                std([ squeeze(fr(:,p_ord,:))],[],2));%,'color',color_cs(2,:,:));
        end
        %legend([real pred],{'data','pred'})
        
    end
end
end

function [fr_per_bin bin_center] = moving_avg_fr(sim_info,spike_times,bin_hlf_wdth,plot_n)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Plot Firing Rate Over Time
    clear bin_center fr_per_bin
   if sim_info.sim_time <1000
       sim_time = sim_info.sim_time*sim_info.dt;
   else
       sim_time = sim_info.sim_time;
   end
   if isempty(bin_hlf_wdth)
    bin_hlf_wdth = 30;%70%40;%65;
   end
    bin_center = sim_info.sim_start_time+bin_hlf_wdth+1:5:sim_time-bin_hlf_wdth;
   % bin_center = bin_hlf_wdth+1:2:sim_info.sim_time-bin_hlf_wdth;

    for n = 1:length(bin_center)
        rel_times = [bin_center(n)-bin_hlf_wdth bin_center(n)+bin_hlf_wdth];
        fr_per_bin(n) = 1e3*sum((spike_times < rel_times(2)) & ...
            (spike_times > rel_times(1)))/(rel_times(2) - rel_times(1));
    end
    bin_center = bin_center ;
    if ~isempty(plot_n)
   figure(plot_n);
   plot(bin_center, fr_per_bin); hold on;
   xlabel('Time (ms)'); ylabel('Firing Rate (sps)')    
    end
end