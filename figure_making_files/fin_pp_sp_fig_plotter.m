 %PP and SP Final Figure Plotter:
%Started 5/1/21 -CRS
%Last Updated 5/7/21 - CRS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Press Run to start in the right directory:
cd('..')
base_dir = pwd;
data_dir = fullfile(base_dir,'relevant_data');
addpath(fullfile(base_dir,'prediction_code'));
%Get nice colormaps
addpath(genpath(fullfile(base_dir,'helper_functions/')))

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Figure 1 B
load(fullfile(data_dir,'1_16_20_collision_sim_Fr_rms_2.mat'))
   
%Original data about pulse rate and spiking rate: 
pulse_rate =  [0 25 50 75 100 175 200 300];
mitchell_res =  [45 50 55 64 75 85 103 110]; %
 all_Ps =  pulse_rate;
     curr_corr = (1/50); 
          tmp_Is = [-15:.01:0];
 
rms_res = vertcat(collision_sim_results_2.rms_t_m);
[rms I_idx]=min(rms_res(30:40,1));

for n_I = 35 %0:40 %length(collision_sim_results_2)
figure(1); plot(pulse_rate,mitchell_res,'k.-'); hold on;
errorbar(pulse_rate,mean(collision_sim_results_2(n_I).fr), ...
    std(collision_sim_results_2(n_I).fr)/sqrt( size(collision_sim_results_2(n_I).fr,1)),'r');
end
xlabel('Pulse Rate (pps)'); ylabel('Firing Rate (sps)')

 %% Plot of max PFR acheive for a given I and given PR
 %% Plots with increase I:

 %In Figure 5 G
 perS_dat = dir(fullfile(data_dir ,'pr_fr_S*_01-15-2023.mat'))

for n_S = 1:7
 q = load(fullfile(data_dir,perS_dat(n_S).name));
 S_val(n_S) =q.per_S.S;
end
 [sortedSs S_ord]=sort(S_val,'ascend');
col_map = parula(44);
for n_S = 1:7
    n_s = S_ord(n_S);
    q = load(fullfile(data_dir,perS_dat(n_s).name));
    s_str =strsplit(perS_dat(n_s).name,'_');
    for n_I = 1:44
        figure(10);
        subplot(1,7,n_S);plot(q.per_S.pulse_rate,mean(q.per_S.pr_fr_dat(:,:,n_I),1) -...
            mean(q.per_S.pr_fr_dat(:,:,1),1),...
            'color',col_map(n_I,:));hold on;
    end
    xlabel('Pulse Rate (pps)'); ylabel('dFiring Rate (sps)'); box off;
    set(gca,'fontsize',15); title(['S = ' s_str{3}(2:end) ' sps'])
    
    pr_fr_perS(n_S,:,:,1) = squeeze(mean(q.per_S.pr_fr_dat,1));
    pr_fr_perS(n_S,:,:,2) = squeeze(std(q.per_S.pr_fr_dat,[],1)/sqrt(10));

end
 [sortedSs S_ord]=sort(S_val,'descend');
%max I val
pr_idxs = 1:2:size(pr_fr_perS,2);
[val max_I_idx] = max(sum(squeeze(max(pr_fr_perS(:,pr_idxs,:,1),[],2)),1));
[val max_pr_idx] = max(sum(squeeze(max(pr_fr_perS(:,pr_idxs,:,1),[],3)),1));

col_perS=winter(7);

 %In Figure 1 D
for n_S = 1:7
    n_s = S_ord(n_S);
    figure(11);
    subplot(1,2,1);
    if sortedSs(n_S) == 0
        shadedErrorBar(q.per_S.pulse_rate(pr_idxs),squeeze(pr_fr_perS(n_s,pr_idxs,max_I_idx,1)),squeeze(pr_fr_perS(n_s,pr_idxs,max_I_idx,2)),...
            'lineProps',{'-','color',  'k'});
        hold on; title(sprintf('Max I %d',q.per_S.I(max_I_idx)*-20));
        xlabel('PR (pps)'); ylabel('Firing Rate')
        subplot(1,2,2);
        shadedErrorBar(q.per_S.I*-20,squeeze(pr_fr_perS(n_s,max_pr_idx,:,1)),squeeze(pr_fr_perS(n_s,max_pr_idx,:,2)),...
            'lineProps',{'-','color',  'k'}); hold on;

    else
        shadedErrorBar(q.per_S.pulse_rate(pr_idxs),squeeze(pr_fr_perS(n_s,pr_idxs,max_I_idx,1)),squeeze(pr_fr_perS(n_s,pr_idxs,max_I_idx,2)),...
            'lineProps',{'-','color',  col_perS(n_S,:)});
        hold on; title(sprintf('Max I %d',q.per_S.I(max_I_idx)*-20));
        xlabel('PR (pps)'); ylabel('Firing Rate')
        set(gca,'fontsize',15)
        subplot(1,2,2);
        shadedErrorBar(q.per_S.I*-20,squeeze(pr_fr_perS(n_s,max_pr_idx,:,1)),squeeze(pr_fr_perS(n_s,max_pr_idx,:,2)),...
            'lineProps',{'-','color',  col_perS(n_S,:)}); hold on;
        set(gca,'fontsize',15)
    end
    xlabel('I (uA)')
    title(sprintf('Max PR %d',max_pr_idx*2));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Visualizing specific runs for showing example PFRS and traces in Figures 2 - 3
%Figure 2: Pulse interactions with no Spont Activity in detail:
data_dir_higher_axon = fullfile(data_dir,'specific_runs','3_axon_runs_4_12_21/axon_1_dS_PR_FR_data');
data_dir_facil_axon = fullfile(data_dir,'specific_runs','3_axon_runs_4_12_21/axon_1_facil_Is');

low_I = load(fullfile(data_dir_facil_axon,'pr_fr_sim_I0-90_PR0-350_MInf_S0_R3_04_17_2021_18_02.mat'));
higher_I = load(fullfile(data_dir_higher_axon ,'pr_fr_sim_I0-360_PR0-350_MInf_S0_R5_04_10_2021_09_17.mat'))'

S0_curr_range = [low_I.curr_options*-20 higher_I.curr_options(9:end)*-20];
S0_frs = [mean(low_I.fr,3);mean(higher_I.fr(9:end,:,:),3)];
S0_frs_std = [std(low_I.fr,[],3);std(higher_I.fr(9:end,:,:),[],3)];
figure(4);
pr_range = [0:400];
n_div = [1:5];
for n = 1:length(n_div)
plot(pr_range,pr_range/n_div(n),'k'); hold on;
end
col_s0 = parula(30);%length(S0_curr_range));
cnt = 1;

%Figure 2B
for n_S0_curs = 14:22%length(S0_curr_range)
    plot(low_I.pulse_rate,S0_frs(n_S0_curs,:),'-','color',  col_s0(25-cnt,:),'linewidth',2); hold on;
   %shadedErrorBar(low_I.pulse_rate,S0_frs(n_S0_curs,:),S0_frs_std(n_S0_curs,:),'lineProps',{'-','color',  col_s0(n_S0_curs,:)}); hold on;
   cnt = cnt +1;
end
 plot(low_I.pulse_rate,S0_frs(n_S0_curs,:),'k-','linewidth',2); hold on;
  
xlabel('Pulse Rate (pps)'); ylabel('Firing Rate (sps)');
set(gca,'fontsize',14); box off;


%% Do predictions with and with out various pulse-pulse interaction rules:
%Figure 2 F
clear rms
figure(5);
% For big plot:
plot_Is = 1:length(S0_curr_range)
n_cnt =1;
for n_curs = plot_Is
        subplot(6,8,n_curs)

         I_cur = S0_curr_range(n_curs);
            S_cur = 0;%
            prs_cur = low_I.pulse_rate;
           
            [tot_pred_f] = interp_pred_fr_v2(I_cur,S_cur, prs_cur,[1 1]); % choos which rules to turn on/off
            [tot_pred_f1] = interp_pred_fr_v2(I_cur,S_cur, prs_cur,[1 0]); % choos which rules to turn on/off
            [tot_pred_f0] = interp_pred_fr_v2(I_cur,S_cur, prs_cur,[0 0]); % choos which rules to turn on/off
       
            shadedErrorBar(low_I.pulse_rate,S0_frs(n_curs,:),S0_frs_std(n_curs,:) ,'lineProps',{'k-'});

            hold on;
            
            
            plot(low_I.pulse_rate,tot_pred_f,'g-');
            plot(low_I.pulse_rate,tot_pred_f1,'b-');
            plot(low_I.pulse_rate,tot_pred_f0,'r-');
            
            rms_vals(n_curs) = rms(tot_pred_f - S0_frs(n_curs,:));
            title(['I = ' num2str(I_cur)]); 
            xlabel('Pulse Rate (pps)');
            ylabel('Firing Rate (sps)');
            set(gca,'fontsize',12)
            n_cnt =n_cnt +1;
end
[mean(rms_vals) std(rms_vals)]

%========================================================================
%=========================================================================
%% Show how dynamics/Voltage show the pp effects:

%expt.num = [] 1-5 Number is the order. Empty is just simple run that can
%be visualized
expt_name = {'pulse_adapt_gen','pulse_adapt_best_mitchell',...
    'pulse_fr_gen','pulse_fr_best_mitchell','prm'};   
expt.num = []; 
run_mode = 'override';%  {'exact','override'}; %can run the exact experiment from study, override some parameters, or do a new experiment
%%% If choose override skip to line 109 to edit otherwise select experiment

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Deciding what outputs to visualize:
output.vis_plot = 1; %If want to see the afferent model APs without experiments
output.vis_plot_num = 6; %plot number when visualizing
output.label_aps = 0; %This is meaningless if don't set the seed, etc. - for check if AP spont or pulse induced
output.all_spk = 0;
output.do_phase_plane_anal = 0;
output.demo_pulse_mod = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%% If overriding - choosing specific parameters etc:
%Changing these settings allows for the visualizations in Figures 2 3, and Supplemental Figure 6
pulse_rate = [100 250 300];
%[70:5:120]%[90 100 110]%[125 150 175 200]; %[225 250 275 300 325];%[25:25:300]; %180;%%[50 80 120 150 200];%100 150 200 250 300 ]%0:5:350;%[0 25 50 200];
curr_options = -2.5;%-9.36; 

[override] = set_overrides_v2(run_mode,output,{'pulse_rate',pulse_rate },{'curr_options',curr_options});
override.sim_info.inj_cur = [1 0];
%RUN EXPERIMENTS FROM HERE ('exact') settings are in this code:
output = run_chosen_expt(expt,run_mode,override,output);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Figure 3: Spont- Pulse Interactions
% Figure 3 B (PxS, P|S rules as I increases)
t_ref_P = 3;
t_ref_S = 3;
ISI = round(1e3/3);
IPI = round(1e3./[1:300]);%50;

common_ms = lcm(ISI,IPI);
P_PiS_SiP = [(floor(common_ms/IPI)*t_ref_P)./common_ms; ...
(floor(common_ms./ISI).*t_ref_S)./common_ms]
figure(6); subplot(2,1,1);
plot([1:300],min(1,.02*[1:300]),'r'); hold on;
plot([1:300],min(1,.005*[1:300]),'b');
plot([1:300],min(1,.001*[1:300]),'g');
box off; set(gca,'fontsize',14);ylabel('P(PxS)')
subplot(2,1,2);
plot([1:300],.8*ones(size([1:300])),'r'); hold on;
plot([1:300],.5*ones(size([1:300])),'b');
plot([1:300],.1*ones(size([1:300])),'g');
ylim([0 1]); xlabel('Pulse Rate (pps)'); ylabel('P(P|S)')
box off; set(gca,'fontsize',14)

%% All traces in different colors for visualizing P-S interactions: 
%Using for Figure 3 C-D
n_S=5;
    low_I = load(fullfile(data_dir_facil_axon,low_file_names{n_S}));
    higher_I = load(fullfile(data_dir_higher_axon,high_file_names{n_S}));
S_curr_range = [low_I.curr_options*-20 higher_I.curr_options(9:end)*-20];
S_frs = [mean(low_I.fr,3);mean(higher_I.fr(9:end,:,:),3)];
S_frs_std = [std(low_I.fr,[],3);std(higher_I.fr(9:end,:,:),[],3)];
figure(2);
pr_range = [0:400];

col_amp = parula(length(S_curr_range));


for n_S_curs = 1:15%length(S_curr_range) %0:44%12:20%
     
    I_cur = S_curr_range(n_S_curs);
    S_cur = S_frs(n_S_curs,1);%mean(squeeze(higher_I.fr(n_S_curs,1,:)));%
    prs_cur = low_I.pulse_rate;
    [tot_pred_f] = interp_pred_f_5_5_21(I_cur,S_cur, prs_cur);%,[1 1]);
    frs_fin = S_frs(n_S_curs,:);% - S_frs(1,:);
    
    shadedErrorBar(low_I.pulse_rate,frs_fin ,S_frs_std(n_S_curs,:)/sqrt(5),'lineProps',{'-','color',  col_amp( n_S_curs ,:)}); hold on;
     
end
xlabel('Pulse Rate (pps)'); ylabel('Firing Rate (sps)');
set(gca,'fontsize',14); colorbar;

%% Show histograms of pulsatile v. spontaneous timed APs
%Making the histograms
%Figure 3 B
expt.num = []; %could be [1 - 7]
run_mode = 'override';%  {'exact','override'}; %can run the exact experiment from study, override some parameters, or do a new experiment
%%% If choose override skip to line 109 to edit otherwise select experiment

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Deciding what outputs to visualize:
output.vis_plots = 0; %If want to see the afferent model APs without experiments
output.vis_plot_num = 6; %plot number when visualizing
output.label_aps = 0; %This is meaningless if don't set the seed, etc. - for check if AP spont or pulse induced
output.all_spk = 0;
output.do_phase_plane_anal = 0;
output.demo_pulse_mod = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Experiment settings:
%%%%%%%%%%%%%% Different experiments
%Can choose to run all three experiments or just one:

%expt.num = [] 1-6 information about them in the readme. Setting [], 3, 5 and
%6 most useful for this paper

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%% If overriding - choosing specific parameters etc:
pulse_rates = [25:25:300];
use_curs = 48/-20;%[72 108 144 192 276 312]/-20;
[override] = set_overrides_v2(run_mode,output,{'pulse_rate',pulse_rates},{'curr_options',use_curs},{'tot_reps', 1},{'mu_IPT',1},{'sim_time',1150});

%RUN EXPERIMENTS FROM HERE ('exact') settings are in this code:
%run_chosen_expt(expt,run_mode,override,output);

%%
%CHANGE THE DIRECTORY :
pl_data_dir = '/Users/cynthiasteinhardt/Dropbox/single-neuron-stim-model/vestibular-neuron-models/vest_model_pulsatile/simpler_format/useful_sim_data/phase_lock_AP_test';
cd(pl_data_dir)
curr_options = [144];%48 72 252 312];% 252;% [ -3.6000   -5.4000   -7.2000   -9.6000  -13.8000  -15.6000]*-20;
mus = [.25 .5 1 2];% Try for each to see difference
pulse_rate = [25 50 75 100 150 175 250 300];%[25:25:300];

tmp = get(0, 'Screensize');
for n_cur_options = 1:length(curr_options)
    
    rel_fils= dir(sprintf('pr_pl_pAP_timing_I%s*mu1*5_4_21.mat',num2str(curr_options(n_cur_options))));
    for n_f = 1:length(rel_fils)
        dat = load(rel_fils(n_f).name);
        info_tmp = strsplit(rel_fils(n_f).name,'_');
        subplot_idx = find(pulse_rate == round(str2num(info_tmp{6}(3:end))));
        if ~isempty(subplot_idx)
            figure(n_cur_options*100)
            
            subplot(1, 8,subplot_idx);
            
            for n_p = 1:length(dat.pl_timing.APs)
                t_ap_after_p_pre_ipi = dat.pl_timing.APs(n_p).spk(dat.pl_timing.APs(n_p).spk > 0); % just counting after 0 per each spike
           if isempty(t_ap_after_p_pre_ipi)     
                n_spks(n_p) = 0;% length(dat.pl_timing.APs(n_p).spk);
           else
                n_spks(n_p) = length(t_ap_after_p_pre_ipi);
           end
            
            end

            %edges = [-.5:1:5.5];
            hist_info = histogram(n_spks);%dat.pl_timing.nAPs,'BinEdges',edges);
            perc_nap = hist_info.Values/length(n_spks);
            num_aps =hist_info.BinEdges(1:end-1) +hist_info.BinWidth/2;
            
            bar(num_aps+1,perc_nap);
            title(sprintf('AP/p = %s', num2str(round(mean(n_spks),3))));
            xticklabels({0:5})
            xlabel('Num APs within IPI (ms)');
            ylabel('% of pulses')
            xlim([0 6])
            set(gca,'fontsize',14)
            %
        end
    end
    set(gcf, 'Position', [tmp(1:2) tmp(3) tmp(4)/4] )
   saveas(gcf, sprintf('ppl_hist_t_I%s_pps_num_5_6_21.eps',num2str(curr_options(n_cur_options))), 'epsc');

    figure(n_cur_options)
     set(gcf, 'Position', [tmp(1:2) tmp(3) tmp(4)/4] );
    for n_f = 1:length(rel_fils)
           dat = load(rel_fils(n_f).name);
        info_tmp = strsplit(rel_fils(n_f).name,'_');
        subplot_idx = find(pulse_rate == round(str2num(info_tmp{6}(3:end))));
        if ~isempty(subplot_idx)
        subplot(1,8, (subplot_idx));
        hist_timing = histogram(dat.pl_timing.t_tots,11);
        
        bin_wdt = hist_timing.BinWidth/2;
        perc_times = hist_timing.Values;%/sum(hist_timing.Values); % only existing pulses
            num_t_bins =hist_timing.BinEdges(1:end-1) + bin_wdt;
         %        tot_APS(n_f) = sum(hist_timing.Values);
          cla;  
          phase_wind  = 2;
          dat_mod = mod(dat.pl_timing.t_tots,dat.ipi);
     %  def_SAP_rate(subplot_idx) =  sum(dat_mod > phase_wind)/(dat.ipi - phase_wind);
        bar( num_t_bins,perc_times,.7);% hold on;
        title(sprintf('PR = %s ',num2str(1e3./dat.ipi)));
        %num2str(sum(~isnan(dat.pl_timing.t_tots))/length(dat.p_times))));
        xlim([-dat.ipi dat.ipi])
        xlabel('Time APs after Pulse (ms)');
          set(gca,'fontsize',14)
    
        end
    end

     disp(['I = ' num2str(curr_options(n_cur_options))])
     disp([pulse_rate; def_SAP_rate] )
   suptitle(['I = ' num2str(curr_options(n_cur_options))])
   saveas(gcf, sprintf('ppl_hist_t_I%s_pps_timing_5_6_21_v2.eps',num2str(curr_options(n_cur_options))), 'epsc');
    
end
%%
%% More concise version of histograms directly above:
tmp = get(0, 'Screensize');
for n_cur_options = 1:length(curr_options)
    
    rel_fils= dir(sprintf('pr_pl_pAP_timing_I%s*mu1*.mat',num2str(curr_options(n_cur_options))));
    for n_f = 1:length(rel_fils)
        dat = load(rel_fils(n_f).name);
        info_tmp = strsplit(rel_fils(n_f).name,'_');
        subplot_idx = find(pulse_rate == round(str2num(info_tmp{6}(3:end))));
            figure(n_cur_options*100)
           
          set(gcf, 'Position', [tmp(1:2) tmp(3) tmp(4)/4] );
           
        if ~isempty(subplot_idx)
            subplot(1, 8,subplot_idx);
            for n_p = 1:length(dat.pl_timing.APs)
            n_spks(n_p) = length(dat.pl_timing.APs(n_p).spk);
            has_spk(n_p)  =sum(~isnan(dat.pl_timing.APs(n_p).spk));
            end
            
            t_after_p = mod(dat.pl_timing.t_tots,dat.ipi);
            
           t_phase_lock = 3; %ms after pulse
           % phase_lock_measure=     (dat.pl_timing.t_tots < 0) & (dat.pl_timing.t_tots <= -dat.ipi+t_phase_lock);
            phase_lock_measure = ( t_after_p <= t_phase_lock);
            no_ps_pl_nopl = [sum(isnan(t_after_p))/length(t_after_p);
            sum(phase_lock_measure)/length(t_after_p);
            sum((~phase_lock_measure)&(~isnan(t_after_p)))/length(t_after_p)];
        

        
            bar(0,no_ps_pl_nopl(1),'b'); hold on;
            bar(1,no_ps_pl_nopl(2:3),'stacked');
            ylim([0 1])
           title(sprintf('PR = %s',num2str(1e3./dat.ipi)));
%             accurate_info = histogram(dat.pl_timing.nAPs);
%             pulse_per_num = accurate_info.Values;
%             num_APs =  accurate_info.BinEdges(1:end-1)+  accurate_info.BinWidth/2;
            
%             bar(num_APs,pulse_per_num./length(dat.p_times));
      
             xticks([0 1]);%
             xticklabels({'No','1+ '})
             ylabel('% of pulses')
%             xlim([0 5])s
          % xtickangle(25)
          set(gca,'fontsize',14)
           
        end
    end
    suptitle(['I = ' num2str(curr_options(n_cur_options)) '  mu = ' num2str(dat.sim_info.mu_IPT)]);
  
  saveas(gcf, sprintf('ppl_hist_t_I%s_pps_timing_concise.eps',num2str(curr_options(n_cur_options))), 'epsc');
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Fig 5 things are in ephys_data_analysis_5_5_21.m
%supplementals
%dynamic loop
expt.num = []; 
run_mode = 'override';%  {'exact','override'}; %can run the exact experiment from study, override some parameters, or do a new experiment
%%% If choose override skip to line 109 to edit otherwise select experiment

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Deciding what outputs to visualize:
output.vis_plot = 1; %If want to see the afferent model APs without experiments
output.vis_plot_num = 6; %plot number when visualizing
output.label_aps = 0; %This is meaningless if don't set the seed, etc. - for check if AP spont or pulse induced
output.all_spk = 0;
output.do_phase_plane_anal = 0;
output.demo_pulse_mod = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%% If overriding - choosing specific parameters etc:
pulse_rate = [45:5:90];%[80 85 90 100 110 120]; %[225 250 275 300 325];%[25:25:300]; %180;%%[50 80 120 150 200];%100 150 200 250 300 ]%0:5:350;%[0 25 50 200];
curr_options = -14.4%-13.8;%-9.36; 

addpath('/Users/cynthiasteinhardt/Dropbox/single-neuron-stim-model/vestibular-neuron-models/vest_model_pulsatile/simpler_format');
[override] = set_overrides_v2(run_mode,output,{'pulse_rate',pulse_rate },{'curr_options',curr_options});

%RUN EXPERIMENTS FROM HERE ('exact') settings are in this code:
run_chosen_expt(expt,run_mode,override,output);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Run different experiments on individual settings and look at outputs
%Example of below S v. above S :
pulse_rate = 20;%[0 25 50 75 100 125 150 200]; %[225 250 275 300 325];%[25:25:300]; %180;%%[50 80 120 150 200];%100 150 200 250 300 ]%0:5:350;%[0 25 50 200];
curr_options = -2.5;%-7.2;%144 uA
inj_cur = [1 0];
output.vis_plot = 1;
[override] = set_overrides_v2(run_mode,output,{'pulse_rate',pulse_rate },...
    {'curr_options',curr_options},{'mu_IPT',1},{'inj_cur',inj_cur });

%RUN EXPERIMENTS FROM HERE ('exact') settings are in this code:
run_chosen_expt(expt,run_mode,override,output);
%% Example of Regular v. Irregular:
output.vis_plots = 1;
run_mode = 'override';
expt.num = [];%[3];
inj_cur = [1 0];
pulse_rate = [150 200 ];%[0:2:360]; %[225 250 275 300 325];%[25:25:300]; %180;%%[50 80 120 150 200];%100 150 200 250 300 ]%0:5:350;%[0 25 50 200];
curr_options = -5;%linspace(0,-18,31);%144 uA
[override] = set_overrides_v2(run_mode,output,{'pulse_rate',pulse_rate },...
    {'curr_options',curr_options},{'mu_IPT',1.65},{'inj_cur',inj_cur},{'is_reg',0},...
    {'tot_reps',1});%3});
disp('Ireg: ')
disp([ override.gNas override.gKHs override.gKLs override.sim_info.mu_IPT])
run_chosen_expt(expt,run_mode,override,output);
%%
expt.num = [];
inj_cur = [1 1];
pulse_rate = 0;%[0:2:360];
curr_options = 0;%linspace(-19.3,-20,5)
[override] = set_overrides_v2(run_mode,output,{'pulse_rate',pulse_rate },...
    {'curr_options',curr_options},{'mu_IPT',.012},{'inj_cur',inj_cur},{'is_reg',1},...
    {'tot_reps',1},{'gNas',25},{'epsc_scale',.004});
disp('Reg: ')
disp([ override.gNas override.gKHs override.gKLs override.sim_info.mu_IPT override.sim_info.epsc_scale])
run_chosen_expt(expt,run_mode,override,output);

%% Between case: %note pulse times do NOT start at zero!
expt.num = [];%[3];
inj_cur = [1 1];
pulse_rate =  [0:4:360];
curr_options = linspace(0,-20,25);%0;%horzcat(linspace(0,-18,31), linspace(-18.15,-20,14));
sim_info.curr_scaling =1;
[override] = set_overrides_v2(run_mode,output,{'pulse_rate',pulse_rate },...
    {'curr_options',curr_options},{'mu_IPT',.03},{'inj_cur',inj_cur},{'is_reg',1},...
    {'tot_reps',1},{'gNas',13});
disp('Reg: ')
disp([ override.gNas override.gKHs override.gKLs override.sim_info.mu_IPT])
run_chosen_expt(expt,run_mode,override,output);
%% Comparison of mod of regular and irregular afferent:
expt.num = [];
expt.num=3;
pulse_rate = [0:5:330]% 0;%[25 100  150]; %[225 250 275 300 325];%[25:25:300]; %180;%%[50 80 120 150 200];%100 150 200 250 300 ]%0:5:350;%[0 25 50 200];
curr_options = linspace(0,-25,41);%-4;%linspace(0,-18,31);%144 uA
[override] = set_overrides_v2(run_mode,output,{'pulse_rate',pulse_rate },...
    {'curr_options',curr_options},{'mu_IPT',1.65},{'inj_cur',inj_cur},{'is_reg',0},...
    {'tot_reps',5});
disp('Ireg: ')
disp([ override.gNas override.gKHs override.gKLs override.sim_info.mu_IPT])
out =run_chosen_expt(expt,run_mode,override,output);

%%
curr_options = linspace(0,-25,41)
pulse_rate =0:5:330;%-10
expt.num = 3;%[];
[override] = set_overrides_v2(run_mode,output,{'pulse_rate',pulse_rate },...
    {'curr_options',curr_options},{'mu_IPT',.09},{'inj_cur',inj_cur},{'is_reg',1},...
    {'tot_reps',5},{'gNas',13});
disp('Reg: ')
disp([ override.gNas override.gKHs override.gKLs override.sim_info.mu_IPT])
out =run_chosen_expt(expt,run_mode,override,output);
%%
figure(1);
for n = 1:length(curr_options)
    subplot(5,9,n)
    errorbar(pulse_rate,mean(fr(n,:,:),3),std(fr(n,:,:),[],3),'.-')
end
%%
q = load('pr_fr_sim_rep5_I0-500_PR0-328_S35.7805_reg0_sim_wind1150_07_03_2021_19_07.mat')

figure(1);
for n = 1:length(q.curr_options)
    subplot(9,5,n)
    plot(q.pulse_rate,mean(q.fr(n,:,:),3),'k')
end
%% Make into plot to compare each:
file_dir = '/Users/cynthiasteinhardt/Dropbox/single-neuron-stim-model/vestibular-neuron-models/vest_model_pulsatile/simpler_format/relev_data';
irreg = load('/Users/cynthiasteinhardt/Dropbox/single-neuron-stim-model/vestibular-neuron-models/vest_model_pulsatile/simpler_format/mitchell_data_all/afferents_data_3/fr_reps_3_steps_10-May-2021_reg_0_spking_1.mat');
%load('fr_reps_5_steps_07-May-2021_reg_0_spking_1.mat');
reg1  = load('/Users/cynthiasteinhardt/Dropbox/single-neuron-stim-model/vestibular-neuron-models/vest_model_pulsatile/simpler_format/fr_reps_3_steps_10-May-2021_reg_1_spking_1.mat');
reg2  = load('/Users/cynthiasteinhardt/Dropbox/single-neuron-stim-model/vestibular-neuron-models/vest_model_pulsatile/simpler_format/fr_reps_2_steps_10-May-2021_reg_1_spking_1.mat');
reg3  = load('/Users/cynthiasteinhardt/Dropbox/single-neuron-stim-model/vestibular-neuron-models/vest_model_pulsatile/simpler_format/fr_reps_1_steps_10-May-2021_reg_1_spking_1.mat')

%%
%load('fr_reps_5_steps_07-May-2021_reg_1_spking_1.mat'); %load('fr_reps_2_steps_10-May-2021_reg_1_spking_1.mat')
all_reg= vertcat(vertcat(mean(reg1.fr,3),reg3.fr),mean(reg2.fr,3));
end_irreg = size(irreg.fr,1);
col_by_I = parula(size(all_reg,1));
figure(1); 

for n_cur = size(irreg.fr,1):-1:1
    subplot(1,2,1);title('Irregular')
  %  subplot(6,5,n_cur)
  shadedErrorBar(irreg.pulse_rate,mean(irreg.fr(n_cur,:,:),3), ...
      std(irreg.fr(n_cur,:,:),[],3)/sqrt(5),...
      'lineProps',{'-','color',col_by_I((size(all_reg,1)- n_cur+1),:) ,...
      'markerfacecolor',col_by_I((size(all_reg,1)- n_cur+1),:)});
  %title(['I = ' num2str(irreg.curr_options(n_cur)*-20)])
end

%figure(2); 

for n_cur = size(all_reg,1):-1:1
     subplot(1,2,2);
     title('Regular')
    %subplot(6,5,n_cur)
  shadedErrorBar(reg1.pulse_rate,all_reg(n_cur,:), zeros(size(all_reg(n_cur,:))),...
      'lineProps',{'-','color',col_by_I((size(all_reg,1)- n_cur+1),:) ,'markerfacecolor',...
      col_by_I((size(all_reg,1)- n_cur+1),:)}); hold on;
 % title(['I = ' num2str(reg1.curr_options(n_cur)*-20)])
end

%% Look into jitter in pulse timing 
expt.num = [];
run_mode = 'override';
inj_cur = [1 0];
pulse_rate =  400;%linspace(0,360,10)%[0:2:360];
curr_options = -12%linspace(0,-18,5)%linspace(0,-18,31);%0;%horzcat(linspace(0,-18,31), linspace(-18.15,-20,14));
[override] = set_overrides_v2(run_mode,output,{'pulse_rate',pulse_rate },...
    {'curr_options',curr_options},{'mu_IPT',.5},{'inj_cur',inj_cur},{'is_reg',0},{'do_jitter',0},{'tot_reps',1});
disp([ override.gNas override.gKHs override.gKLs override.sim_info.mu_IPT])
run_chosen_expt(expt,run_mode,override,output);

%% See whether jitter distorts these effect with jitter of 2 ms around pulse time - 1 second long simulations
 q =load('pr_fr_sim_rep5_I0-360_PR0-360_S84.1366_reg0_05_23_2021_15_18.mat') % here Jitter = 2 ms std

% load('/Users/cynthiasteinhardt/Dropbox/single-neuron-stim-model/vestibular-neuron-models/vest_model_pulsatile/simpler_format/relev_data/reg_irreg_simulations/pr_fr_sim_rep1_I0-360_PR0-360_S85.1992_reg0_05_22_2021_21_04.mat')
 figure(100);
 for n_cur = 1:length(q.curr_options)
     subplot(6,6,n_cur)
       
    shadedErrorBar(q.pulse_rate,mean(q.fr(n_cur,:,:),3) - mean(q.fr(1,:,:),3),std(q.fr(n_cur,:,:),[],3),...
       'lineProps',{'-'}); hold on;
 end
 
 %% Shorten simulation window and test if effects still remain
 sim_winds = [500 250 100 50 25 10 ]% ms
 for n_lens = 1:length(sim_winds)
     expt.num = [3];
     inj_cur = [1 1];
     pulse_rate =  0:2:360;%[0:2:360];
     curr_options = linspace(0,-18,16);%linspace(0,-18,31);%0;%horzcat(linspace(0,-18,31), linspace(-18.15,-20,14));
     [override] = set_overrides_v2(run_mode,output,{'pulse_rate',pulse_rate },...
         {'curr_options',curr_options},{'mu_IPT',.5},{'inj_cur',inj_cur},{'is_reg',0},...
         {'do_jitter',0},{'tot_reps',5},{'sim_time',[sim_winds(n_lens) + 150]});
     disp([ override.gNas override.gKHs override.gKLs override.sim_info.mu_IPT])
     run_chosen_expt(expt,run_mode,override,output);
 end
 %% Visualize difference with time window:
%data_dir = '/Users/cynthiasteinhardt/Dropbox/single-neuron-stim-model/vestibular-neuron-models/vest_model_pulsatile/simpler_format/relev_data/reg_irreg_simulations/newer';
%data_dir = '/Users/cynthiasteinhardt/Dropbox/Fridman_lab/submissions/pulsatile/pp_sp_ps_paper/pp_sp_figures/simwindowandjitter';
data_dir = '/Users/cynthiasteinhardt/Dropbox/Fridman_lab/submissions/pulsatile/pp_sp_ps_paper/pp_sp_figures/10_rep_sim_winds';
cd(data_dir);
files = dir('pr_fr_*rep1*sim_wind*')
figure(11);
cols = spring(7)
len_ords = [160   175   400   650   250   200];
[wind_len_ord  idx_ord1]= sort(len_ords);
for n_f= 1:length(files)
    files(n_f).name
    file_info = strsplit(files(n_f).name,'_');
     dat = load(files(n_f).name);
    subplot(2,4,(n_f))
     for n_cur = 1:4:16
    shadedErrorBar(dat.pulse_rate,mean(dat.fr(n_cur,:,:),3),std(dat.fr(n_cur,:,:),[],3), 'lineProps',{'-'}); hold on;
    ylim([0 160]); title(['Sim Len = ' file_info{10}(5:end) ' ms'])
    xlabel('Pulse Rate (pps)'); ylabel('Firing Rate (sps)')
     end
    all_frs(n_f,:,:) = mean(dat.fr,3);
    wind_len(n_f) = str2num(file_info{10}(5:end));
end
[val max_idx]=max(wind_len)
[wind_len_ord  idx_ord]= sort(wind_len);
%% 5 is the largest

for n_ax  =1:6
    idx_ord(n_ax)
    wind_diff(n_ax,:) = rms(squeeze(all_frs(max_idx,:,:) - all_frs(idx_ord(n_ax),:,:)),2);
    power_500ms(n_ax,:) = rms(squeeze(all_frs(max_idx,:,:)),2);
end

spont_rate(1:6,:) = abs((all_frs(max_idx,:,1)) - (all_frs(idx_ord,:,1))); % diffvariance in spont rate
per_spont = [mean(spont_rate,2)./mean(all_frs(max_idx,:,1)) std(spont_rate,[],2)./mean(all_frs(max_idx,:,1))];
xlabel('Window Length (ms)'); ylabel('RMS (sps)'); box off; set(gca,'fontsize',14);
figure(100);subplot(2,1,1);
errorbar(wind_len_ord- 150,mean(wind_diff,2),std(wind_diff,[],2),'.-','markersize',15);
box off;set(gca,'fontsize',14);
ylabel('Difference (sps)')
subplot(2,1,2); 
errorbar(wind_len_ord- 150,mean(wind_diff(:,:)./power_500ms(:,:),2)*100, std(wind_diff./power_500ms,[],2)*100,'.-','markersize',15);
hold on;
errorbar(wind_len_ord- 150,per_spont(:,1)*100,per_spont(:,2)*100,'.-','markersize',15)
box off;
xlabel('Window Length (ms)');  ylabel('Difference (%)')
set(gca,'fontsize',14);
%% Initial pulse rate/amplitude modulation experiments: 5/31/21

%% High Rate
expt.num = []; 
run_mode = 'override';%  {'exact','override'}; %can run the exact experiment from study, override some parameters, or do a new experiment
%%% If choose override skip to line 109 to edit otherwise select experiment

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Deciding what outputs to visualize:
output.vis_plots = 1; %If want to see the afferent model APs without experiments
output.vis_plot_num = 6; %plot number when visualizing
output.label_aps = 0; %This is meaningless if don't set the seed, etc. - for check if AP spont or pulse induced
output.all_spk = 0;
output.do_phase_plane_anal = 0;
output.demo_pulse_mod = 0;
inj_cur = [1 0];
pulse_rate = [1200];%[25 50 75 100 150 175 200 300];%30:10:70;
curr_options = -16.75;%linspace(0,-18,31);%0;%horzcat(linspace(0,-18,31), linspace(-18.15,-20,14));
[override] = set_overrides_v2(run_mode,output,{'pulse_rate',pulse_rate },...
    {'curr_options',curr_options},{'mu_IPT',1.3},{'inj_cur',inj_cur},{'is_reg',0},{'do_jitter',0},{'tot_reps',1},{'epsc_scale',1});
disp([ override.gNas override.gKHs override.gKLs override.sim_info.mu_IPT])
run_chosen_expt(expt,run_mode,override,output);

%% Behavior link to pr-fr relationship 
%Della santina 2007 / sadeghi et al. 2007
f_max = 350;
f_baseline = 100;
C = 5;% iregular 2 - regular?
HV_i = -450:450%[0:4095];%0-2048-4095 = [-450, 0, +450]
A = atanh(2*f_baseline./f_max -1);
fr = 0.5*f_max.*(1+tanh(A+C*((HV_i + 450)/450 - 1))); %firing rate for each head velocity
%dT = 1./f;

figure(1); subplot(2,1,1); plot(HV_i,fr);
xlabel('Head  Veloctiy (degrees)'); ylabel('Firing Rate (sps)')
title('Natural irregular firign rate to head velocity');


%Invert it to convert firing rate to head velocity: (done on paper)
fr_i = [0:350];
HV = 450*(1+ ((atanh((fr_i/(.5*f_max)) - 1) - A)/C)) - 450;
figure(1); subplot(2,1,2); plot(fr_i,HV,'k'); hold on;
plot(fr,HV_i,'r--')
xlabel('Firing Rate (sps)'); ylabel('Head Velocity (degrees)')

fr_t_HV = @(fr_i) 450*(1+ ((atanh((fr_i/(.5*f_max)) - 1) - A)/C)) - 450;
% In della santina 2007 used for direct read to pulse rate. See for
% increase pulse rate what head velocity would look like given this
% relatioship:
%%
%LOAD IN SOME SIMULATION TO BEHAVIOR:
data_dir = '/Users/cynthiasteinhardt/Dropbox/single-neuron-stim-model/vestibular-neuron-models/vest_model_pulsatile/simpler_format/pr_fr_4_10_21/'
%'/Users/cynthiasteinhardt/Dropbox/single-neuron-stim-model/vestibular-neuron-models/vest_model_pulsatile/simpler_format/useful_sim_data/sim_diff_spont_rate_data';

%addpath('/Users/cynthiasteinhardt/Dropbox/single-neuron-stim-model/vestibular-neuron-models/vest_model_pulsatile/simpler_format')
data_dir_higher_axon = '/Users/cynthiasteinhardt/Dropbox/single-neuron-stim-model/vestibular-neuron-models/vest_model_pulsatile/simpler_format/useful_sim_data/3_axon_runs_4_12_21/axon_1_dS_PR_FR_data';

%Facillitation:
data_dir_facil_axon = '/Users/cynthiasteinhardt/Dropbox/single-neuron-stim-model/vestibular-neuron-models/vest_model_pulsatile/simpler_format/useful_sim_data/3_axon_runs_4_12_21/axon_1_facil_Is';

low_I = load(fullfile(data_dir_facil_axon,'pr_fr_sim_I0-90_PR0-350_MInf_S0_R3_04_17_2021_18_02.mat'));
higher_I = load(fullfile(data_dir_higher_axon ,'pr_fr_sim_I0-360_PR0-350_MInf_S0_R5_04_10_2021_09_17.mat'))'

S0_curr_range = [low_I.curr_options*-20 higher_I.curr_options(9:end)*-20];
S0_frs = [mean(low_I.fr,3);mean(higher_I.fr(9:end,:,:),3)];
S0_frs_std = [std(low_I.fr,[],3);std(higher_I.fr(9:end,:,:),[],3)];

pr_range = [0:400];

cnt = 1;
use_cols =jet(10)
for n_S0_curs = [14:22 37]%[14:22 35]% length(S0_curr_range)
    figure(4); subplot(2,1,1);
    plot(low_I.pulse_rate,S0_frs(n_S0_curs,:),'-','color',use_cols(cnt,:),'linewidth',2); hold on;
  xlabel('Pulse Rate (pps)'); ylabel('Firing Rate(sps)');
  set(gca,'fontsize',14); box off;
  
    subplot(2,1,2);   
    for n = 1:length(fr)
        [a pr_idx] = min(abs(low_I.pulse_rate - round(fr(n))));
        fr_rel(n) = S0_frs(n_S0_curs,pr_idx);
    end
    q = plot(HV_i,fr,'k','linewidth',2); hold on;
    plot(HV_i,fr_rel,'color',use_cols(cnt,:));
    xlabel('Head Velocity (degrees)'); ylabel('Firing Rate (sps)');
    
    %plot(low_I.pulse_rate,S0_frs(n_S0_curs,:),'-','color',use_cols(cnt,:),'linewidth',2);
  %  plot(low_I.pulse_rate,fr_t_HV(S0_frs(n_S0_curs,:)),'-','color',use_cols(cnt,:),'linewidth',2); hold on;
     
   cnt = cnt +1;
end
legend(q,'Pred Fr')
set(gca,'fontsize',14); box off;

%% More spont activity:

data_dir = '/Users/cynthiasteinhardt/Dropbox/single-neuron-stim-model/vestibular-neuron-models/vest_model_pulsatile/simpler_format/pr_fr_4_10_21/'
%'/Users/cynthiasteinhardt/Dropbox/single-neuron-stim-model/vestibular-neuron-models/vest_model_pulsatile/simpler_format/useful_sim_data/sim_diff_spont_rate_data';

%addpath('/Users/cynthiasteinhardt/Dropbox/single-neuron-stim-model/vestibular-neuron-models/vest_model_pulsatile/simpler_format')
data_dir_higher_axon = '/Users/cynthiasteinhardt/Dropbox/single-neuron-stim-model/vestibular-neuron-models/vest_model_pulsatile/simpler_format/useful_sim_data/3_axon_runs_4_12_21/axon_1_dS_PR_FR_data';

%Facillitation:
data_dir_facil_axon = '/Users/cynthiasteinhardt/Dropbox/single-neuron-stim-model/vestibular-neuron-models/vest_model_pulsatile/simpler_format/useful_sim_data/3_axon_runs_4_12_21/axon_1_facil_Is';

cd(data_dir_facil_axon);
facil_fils= dir('pr_fr_sim*');
cd(data_dir_higher_axon);
highI_fils= dir('pr_fr_sim*');

low_file_names = {'pr_fr_sim_I0-90_PR0-350_MInf_S0_R3_04_17_2021_18_02.mat','pr_fr_sim_I0-90_PR0-350_M8_S4.7059_R3_04_17_2021_17_29.mat',...
    'pr_fr_sim_I0-90_PR0-350_M4_S12.9412_R3_04_17_2021_16_31.mat','pr_fr_sim_I0-90_PR0-350_M2_S35.2941_R3_04_17_2021_15_33.mat',...
    'pr_fr_sim_I0-90_PR0-350_M1_S57.6471_R3_04_17_2021_14_35.mat','pr_fr_sim_I0-90_PR0-350_M0.25_S142.3529_R3_04_17_2021_12_38.mat',...
    'pr_fr_sim_I0-90_PR0-350_M0.5_S89.4118_R3_04_17_2021_13_37.mat'};
high_file_names = {'pr_fr_sim_I0-360_PR0-350_MInf_S0_R5_04_10_2021_09_17.mat','pr_fr_sim_I0-360_PR0-350_M8_S4.7059_R5_04_10_2021_07_56.mat',...
    'pr_fr_sim_I0-360_PR0-350_M4_S12.9412_R5_04_10_2021_05_33.mat','pr_fr_sim_I0-360_PR0-350_M2_S35.2941_R5_04_10_2021_03_09.mat','pr_fr_sim_I0-360_PR0-350_M1_S57.6471_R5_04_10_2021_00_45.mat',...
    'pr_fr_sim_I0-360_PR0-350_M0.25_S142.3529_R5_04_09_2021_19_56.mat','pr_fr_sim_I0-360_PR0-350_M0.5_S89.4118_R5_04_09_2021_22_21.mat'};

% % For visuals:
% low_I = load(fullfile(data_dir_facil_axon,'pr_fr_sim_I0-90_PR0-350_M2_S35.2941_R3_04_17_2021_15_33.mat'));
% %%'pr_fr_sim_I0-90_PR0-350_M4_S12.9412_R3_04_17_2021_16_31.mat'));%%'pr_fr_sim_I0-90_PR0-350_M8_S4.7059_R3_04_17_2021_17_29.mat'));
% higher_I = load(fullfile(data_dir_higher_axon ,'pr_fr_sim_I0-360_PR0-350_M2_S35.2941_R5_04_10_2021_03_09.mat'));%'pr_fr_sim_I0-360_PR0-350_M4_S12.9412_R5_04_10_2021_05_33.mat'));%'pr_fr_sim_I0-360_PR0-350_M8_S4.7059_R5_04_10_2021_07_56.mat'));
col_s0 = winter(7);
for n_S = 5%1:3
    low_I = load(fullfile(data_dir_facil_axon,low_file_names{n_S}));
    higher_I = load(fullfile(data_dir_higher_axon,high_file_names{n_S}));
S_curr_range = [low_I.curr_options*-20 higher_I.curr_options(9:end)*-20];
S_frs = [mean(low_I.fr,3);mean(higher_I.fr(9:end,:,:),3)];
S_frs_std = [std(low_I.fr,[],3);std(higher_I.fr(9:end,:,:),[],3)];
figure(9);
pr_range = [0:400];

%addpath('/Users/cynthiasteinhardt/Dropbox/Fridman_lab/submissions/pulsatile/pp_sp_ps_paper/pp_sp_figures/github_repo')
%col_s0 = parula(30);%length(S0_curr_range));

cnt = 1;
leg_nums ={};
for n_S_curs = 25 %10:5:44%:44%12:20%length(S_curr_range)
    %subplot(3,6,n_S_curs);
      S_cur = S_frs(n_S_curs,1)
    I_cur = S_curr_range(n_S_curs);
    leg_nums{cnt} = [num2str(I_cur) ' uA'];
    S_cur = S_frs(n_S_curs,1);%mean(squeeze(higher_I.fr(n_S_curs,1,:)));%
    prs_cur = low_I.pulse_rate;
    frs_fin = S_frs(n_S_curs,:);
    subplot(2,1,1);
    % plot(low_I.pulse_rate,S0_frs(n_S0_curs,:),'-');%,'color',  col_s0(25-cnt,:),'linewidth',2); hold on;
    %shadedErrorBar(low_I.pulse_rate,frs_fin ,S_frs_std(n_S_curs,:),'lineProps',{'k-'});%,'color',  col_s0(n_S0_curs,:)}); hold on;
    shadedErrorBar(low_I.pulse_rate,frs_fin,S_frs_std(n_S_curs,:),'lineProps',{'-','color',  col_s0(cnt,:)}); hold on;
   xlabel('Pulse Rate (pps)'); ylabel('Firing Rate (sps)')
    set(gca,'fontsize',12); box off;
     subplot(2,1,2)
      
    for n = 1:length(fr)
        [a pr_idx] = min(abs(low_I.pulse_rate - round(fr(n))));
        fr_rel(n) = S_frs(n_S_curs,pr_idx);
    end
    plot(HV_i,fr_rel,'-','color',  col_s0(cnt,:)); hold on;
  q = plot(HV_i,fr,'k','linewidth',2); hold on;
      % shadedErrorBar(low_I.pulse_rate,fr_t_HV(frs_fin-frs_fin(:,1)+100),S_frs_std(n_S_curs,:),'lineProps',{'-','color',  col_s0(cnt,:)}); hold on;
  %xlabel('Pulse Rate (pps)'); ylabel('Eye angular Velocity (degrees)')
    hold on;
    cnt = cnt +1;
    set(gca,'fontsize',12); box off;
    
end
%plot(low_I
end
legend( leg_nums)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Repeat pulse rate modulation with respect to HV-pulse rate conversion: 
%%Last updated 7/2/21
%%Add in loop over different sine freq, specified externally, PRM/PAM equiv ranges
%%%%%%%%%%%%%%

%% Plot predicted current-pulse relationship:
%Fig 5 right plots
expt.num = [6]; 
run_mode = 'override';%  {'exact','override'}; %can run the exact experiment from study, override some parameters, or do a new experiment
%%% If choose override skip to line 109 to edit otherwise select experiment
%Two example experiment: for PAM:   60+-20 uA 250 pps see somewhat linear
%increase( fig 2)
%PRM consistently linear until linear: 60 +-20 pps 
%both predictible inconsisntetly 150 uA 150 pps +-50 and vice versa
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Deciding what outputs to visualize:
output.vis_plots = 0; %If want to see the afferent model APs without experiments
output.vis_plot_num = 6; %plot number when visualizing
output.label_aps = 0; %This is meaningless if don't set the seed, etc. - for check if AP spont or pulse induced
output.all_spk = 0;
output.do_phase_plane_anal = 0;
output.demo_pulse_mod = 0;
inj_cur = [1 1];

n_steps = 6;
%PAM
pulse_rate = 150;
curr_options = linspace(100,200,n_steps)/-20;%150 uA baseline/ fixed point for PRM/PAM
[override] = set_overrides_v2(run_mode,output,{'pulse_rate',pulse_rate },...
    {'curr_options',curr_options},{'mu_IPT',1.5},{'inj_cur',inj_cur},{'is_reg',0},{'do_jitter',0},...
    {'tot_reps',10},{'sim_start_time',150},{'epsc_scale',1},{'sim_time',1150});

disp([ override.gNas override.gKHs override.gKLs override.sim_info.mu_IPT])

figure(30); subplot(2,2,1);
run_chosen_expt(expt,run_mode,override,output);

pulse_rate = [250];
curr_options = linspace(40,80,n_steps)/-20;%150 uA baseline/ fixed point for PRM/PAM
[override] = set_overrides_v2(run_mode,output,{'pulse_rate',pulse_rate },...
    {'curr_options',curr_options},{'mu_IPT',1.5},{'inj_cur',inj_cur},{'is_reg',0},{'do_jitter',0},...
    {'tot_reps',10},{'sim_start_time',150},{'epsc_scale',1},{'sim_time',1150});

subplot(2,2,2);
run_chosen_expt(expt,run_mode,override,output);

%PRM
pulse_rate = linspace(100,200,n_steps);
curr_options = 150/-20;%150 uA baseline/ fixed point for PRM/PAM
[override] = set_overrides_v2(run_mode,output,{'pulse_rate',pulse_rate },...
    {'curr_options',curr_options},{'mu_IPT',1.5},{'inj_cur',inj_cur},{'is_reg',0},{'do_jitter',0},...
    {'tot_reps',10},{'sim_start_time',150},{'epsc_scale',1},{'sim_time',1150});
subplot(2,2,3);
run_chosen_expt(expt,run_mode,override,output);

pulse_rate = linspace(60,160,n_steps);
curr_options = 150/-20;%150 uA baseline/ fixed point for PRM/PAM
[override] = set_overrides_v2(run_mode,output,{'pulse_rate',pulse_rate },...
    {'curr_options',curr_options},{'mu_IPT',1.5},{'inj_cur',inj_cur},{'is_reg',0},{'do_jitter',0},...
    {'tot_reps',10},{'sim_start_time',150},{'epsc_scale',1},{'sim_time',1150});
subplot(2,2,4);
run_chosen_expt(expt,run_mode,override,output);
%% Figure 5 A-C/ Supplementa Figure 4 PRM/PAM Experiments with diff frequency modulation:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
expt.num = [5]; 
run_mode = 'override';%  {'exact','override'}; %can run the exact experiment from study, override some parameters, or do a new experiment
%%% If choose override skip to line 109 to edit otherwise select experiment


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Deciding what outputs to visualize:
output.vis_plots = 0; %If want to see the afferent model APs without experiments
output.vis_plot_num = 6; %plot number when visualizing
output.label_aps = 0; %This is meaningless if don't set the seed, etc. - for check if AP spont or pulse induced
output.all_spk = 0;
output.do_phase_plane_anal = 0;
output.demo_pulse_mod = 0;
inj_cur = [1 1];

dt = 1e-6; %s
clear sim_fr sim_pr sim_corrs sim_ts sim_mod sim_corr_prs
freq_plot = 1;
freq_tests= [.25 .5 1 2 4 8 16 32 64 81 100];
l_freq = length(freq_tests);
%n_reps = 1; % example

%Combinations from above:
n_ms = [2 2 1 1];
pr_cent  = [150 250 150 110];
pa_cent = [150 60 150 150];
mod_d = [50 20 50 50];
%prs = [150 250 100:200 50:90];
%pas = [100:200 40:80 150 150];


%Choose to do 150 +-50 for each and 120 +- 50 to show two diff extremes bot
%hexplainable w/ 1 second loops
for n_combos = 1:length(n_ms)
    firing = struct();
    n_modes = n_ms(n_combos);
firing.pm_mod_amp = mod_d(n_combos); %50 pps/50uA - modulation of whatever
firing.pr_base = pr_cent(n_combos);%pps
firing.pa_base = pa_cent(n_combos);%uA
if n_modes == 2
    firing.pm_base = firing.pa_base;
else
     firing.pm_base = firing.pr_base;
end
for n_freq = 1:length(freq_tests)
firing.sim_time = 4;%10;
t_full = 0:dt:firing.sim_time-dt; %s
%firing.mod_f = HV_sin;%HV_t_pr(HV_sin);
firing.mod_timing = t_full;
    firing.mod_freq = 2;% Hz

inj_cur = [1 1];
pulse_rate = firing.pr_base;
curr_options = firing.pa_base/-20;%uA baseline/ fixed point for PRM/PAM
[override] = set_overrides_v2(run_mode,output,{'pulse_rate',pulse_rate },...
    {'curr_options',curr_options},{'mu_IPT',1.5},{'inj_cur',inj_cur},{'is_reg',0},{'do_jitter',0},...
    {'tot_reps',1},{'sim_start_time',150},{'epsc_scale',1},{'sim_time',firing.sim_time*1e3});

firing.mod_f = firing.pm_mod_amp*sin(firing.mod_freq*2*pi*t_full)+firing.pm_base;

override.firing = firing;
override.sim_info.sim_time = override.firing.sim_time*1e3;
if (n_modes ==1)
    override.rate_mode = 1; % 1 = rate mode, 0 = amplitude mode
else
    override.rate_mode = 0;
end
disp(sprintf('PRM:%s,Freq:%s,EPSC rate(ms):%s',num2str(override.rate_mode), ...
    num2str(firing.mod_freq), num2str(override.sim_info.mu_IPT)));
for n_reps = 1:10
out = run_chosen_expt(expt,run_mode,override,output);
sim_corrs(n_combos,n_reps,n_freq,:) = out.corr;%_mdf;
%sim_corr_prs(n_combos,n_reps,n_freq,:) = out.corr_pr;
sim_fr(n_combos,n_reps,n_freq,:) = out.fr_vect;
%sim_mod(n_combos,n_reps,n_freq,:) = out.mod_vect;
sim_pr(n_combos,n_reps,n_freq,:) = out.pr_vect;
sim_ts(n_combos,n_reps,n_freq,:) = out.t_vect;
end
end
end

freq_use_idx = 3;
use_mod = squeeze(sim_mod(:,:,freq_use_idx,:));
use_fr = squeeze(sim_fr(:,:,freq_use_idx,:));
use_t = squeeze(sim_ts(:,:,freq_use_idx,:));

%Plot single example of each
for n = 1:4
figure(1);subplot(2,2,n)
  plot(squeeze(use_t( n,1,:)),...
   (squeeze(mean(use_mod( n,:,:),2))- mean(use_mod(n,:))),'k'); hold on;%/max( (squeeze(sim_mod(1,n_freq,1,:))- firing.pm_base))
if n_ms(n) == 2
shadedErrorBar(squeeze(use_t(n,1,:)),...
    (squeeze(mean(use_fr( n,:,:),2))- mean(use_fr(n,:))), squeeze(std(use_fr( n,:,:),[],2)),'lineProps',{'b-'});
else
    shadedErrorBar(squeeze(use_t(n,1,:)),...
    (squeeze(mean(use_fr( n,:,:),2))- mean(use_fr(n,:))), squeeze(std(use_fr( n,:,:),[],2)),'lineProps',{'r-'});
end
xlim([1000 2000]);
xlabel('Time (ms)'); ylabel('dsps')

% Plot the frequency response:
figure(2);
subplot(2,2,n)
shadedErrorBar(freq_tests,(squeeze(mean(sim_corrs(n,:,:),2))),(squeeze(std(sim_corrs(n,:,:),[],2))),'lineProps',{'k-'})
xlabel('Freq (Hz)'); ylabel('Corr ')
end

%%
%Plot results:

for n = 1:length(freq_tests)

prm_n =squeeze(sim_fr(1,n,:,:));
pam_n =squeeze(sim_fr(2,n,:,:));
figure(21);
%suptitle('PRM')
subplot(4,3,n);
 
shadedErrorBar(sim_ts(1,n,:),mean(pr_prm_n,1)-mean(pr_prm_n(:)),std(pr_prm_n,[],1),'lineProps',{'k-'}); hold on;
shadedErrorBar(sim_ts(1,n,:),(mean(prm_n,1) - mean(prm_n(:))),std(prm_n,[],1),'lineProps',{'r-'}); hold on;
prm_corr(n) = corr(mean(prm_n,1)',mean(pr_prm_n,1)');
%/max(mean(prm_n,1) - mean(prm_n(:)))
if (n > 1)
   xlim([0 (1/freq_tests(n))*1e3]) 
end
title(['PRM ' num2str(freq_tests(n))]);

 figure(22);
subplot(4,3,n);
%suptitle('PAM')
shadedErrorBar(sim_ts(2,n,:),mean(pr_pam_n,1)-mean(pr_pam_n(:)),std(pr_pam_n,[],1),'lineProps',{'k-'}); hold on;
shadedErrorBar(sim_ts(2,n,:),(mean(pam_n,1) - mean(pam_n(:))),std(pam_n,[],1),'lineProps',{'b-'}); hold on;
%/max((mean(pam_n,1) - mean(pam_n(:))))
pam_corr(n) = corr(mean(pam_n,1)',mean(pr_pam_n,1)');
title(['PAM ' num2str(freq_tests(n))]);
if (n > 1)
    xlim([0 (1/freq_tests(n))*1e3]) 
end
end

figure(20);subplot(2,1,1);
avg_corr= mean(sim_corrs,3);
std_corr= std(sim_corrs,[],3);
shadedErrorBar(freq_tests,avg_corr(1,:),std_corr(1,:),'lineProps',{'r.-','markersize',20}); hold on;
shadedErrorBar(freq_tests,avg_corr(2,:),std_corr(2,:),'lineProps',{'b.-','markersize',20})

subplot(2,1,2);
plot(freq_tests,prm_corr,'r.-','markersize',20); hold on;
plot(freq_tests,pam_corr,'b.-','markersize',20);
xlabel('Modulation Freq (Hz)'); ylabel('Correlation to Input');

%%
figure(1);
for n = 1:11
    subplot(4,3,n)
    if (n > 1)
        xlim([(1/freq_tests(n))*1e3 2*(1/freq_tests(n))*1e3])
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Test some stuff
expt.num = []; 
run_mode = 'override';%  {'exact','override'}; %can run the exact experiment from study, override some parameters, or do a new experiment
%%% If choose override skip to line 109 to edit otherwise select experiment

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Deciding what outputs to visualize:
output.vis_plots = 1; %If want to see the afferent model APs without experiments
output.vis_plot_num = 6; %plot number when visualizing
output.label_aps = 0; %This is meaningless if don't set the seed, etc. - for check if AP spont or pulse induced
output.all_spk = 0;
output.do_phase_plane_anal = 0;
output.demo_pulse_mod = 0;
inj_cur = [1 0];
pulse_rate = [300];%[0 150];%30:10:70;
curr_options = -13.8;%
[override] = set_overrides_v2(run_mode,output,{'pulse_rate',pulse_rate },...
    {'curr_options',curr_options},{'mu_IPT',1},{'inj_cur',inj_cur},{'is_reg',0},...
    {'do_jitter',0},{'tot_reps',1},{'epsc_scale',1},{'sim_time',250});
disp([ override.gNas override.gKHs override.gKLs override.sim_info.mu_IPT])
% override.gNas = 6*13;
% override.gKHs = 4*2.8;
run_chosen_expt(expt,run_mode,override,output);

%% Supplemental Figure 6
% Compare regularity
pulse_rate = [115]%[0 115];%[0 150];%30:10:70;
curr_options = -7;%linspace(0,-18,31);%0;%horzcat(linspace(0,-18,31), linspace(-18.15,-20,14));

[override] = set_overrides_v2(run_mode,output,{'pulse_rate',pulse_rate },...
    {'curr_options',curr_options},{'mu_IPT',.8},{'inj_cur',inj_cur},{'is_reg',0},...
    {'do_jitter',0},{'tot_reps',1},{'epsc_scale',1},{'sim_time',450});
disp([ override.gNas override.gKHs override.gKLs override.sim_info.mu_IPT])
override.gNas = 6*13;
override.gKHs = 4*2.8;
run_chosen_expt(expt,run_mode,override,output);

curr_options = [.03 0 -.085];
pulse_rate = 0;
rng(1)
[override] = set_overrides_v2(run_mode,output,{'pulse_rate',pulse_rate },...
    {'curr_options',curr_options},{'mu_IPT',.8},{'inj_cur',inj_cur},{'is_reg',0},...
    {'do_jitter',0},{'tot_reps',1},{'epsc_scale',1},{'sim_time',450},{'isDC',1});
disp([ override.gNas override.gKHs override.gKLs override.sim_info.mu_IPT])
run_chosen_expt(expt,run_mode,override,output);

%%
pulse_rate = 0; curr_options = 0;
[override] = set_overrides_v2(run_mode,output,{'pulse_rate',pulse_rate },...
    {'curr_options',curr_options},{'mu_IPT',1.5},{'inj_cur',inj_cur},{'is_reg',0},...
    {'do_jitter',0},{'tot_reps',1},{'epsc_scale',1},{'sim_time',450},{'isDC',1});
disp([ override.gNas override.gKHs override.gKLs override.sim_info.mu_IPT])
run_chosen_expt(expt,run_mode,override,output);

%% Plot jitter:
%Figure 5 E
dat_dir = '/Users/cynthiasteinhardt/Dropbox/Fridman_lab/submissions/pulsatile/pp_sp_ps_paper/pp_sp_figures/simwindowandjitter';
dat = load(fullfile(dat_dir,'jitter_2_pr_fr_sim_rep5_I0-360_PR0-360_S0_reg0_05_24_2021_13_15.mat'));
dat2 = load(fullfile(dat_dir,'jitter_1_pr_fr_sim_rep5_I0-360_PR0-360_S0_reg0_05_24_2021_11_33.mat'));

data_dir_higher_axon = '/Users/cynthiasteinhardt/Dropbox/single-neuron-stim-model/vestibular-neuron-models/vest_model_pulsatile/simpler_format/useful_sim_data/3_axon_runs_4_12_21/axon_1_dS_PR_FR_data';
higher_I = load(fullfile(data_dir_higher_axon ,'pr_fr_sim_I0-360_PR0-350_MInf_S0_R5_04_10_2021_09_17.mat'))'

figure(70);
plot_cnt =1;
for n_cur = 3:3:length(dat.curr_options)
   subplot(6,4,plot_cnt);
   shadedErrorBar(higher_I.pulse_rate,mean(higher_I.fr(n_cur,:,:),3),std(higher_I.fr(n_cur,:,:),[],3),'lineProps',{'k-'}); hold on;
   shadedErrorBar(dat.pulse_rate,mean(dat.fr(n_cur,:,:),3),std(dat.fr(n_cur,:,:),[],3),'lineProps',{'m-'});
   title(sprintf('I = %s', num2str(-20*dat.curr_options(n_cur))));

   shadedErrorBar(higher_I.pulse_rate,mean(higher_I.fr(n_cur,:,:),3),std(higher_I.fr(n_cur,:,:),[],3),'lineProps',{'k-'}); hold on;
   shadedErrorBar(dat.pulse_rate,mean(dat2.fr(n_cur,:,:),3),std(dat2.fr(n_cur,:,:),[],3),'lineProps',{'g-'});
   title(sprintf('I = %s',num2str(-20*dat.curr_options(n_cur))));
      plot_cnt =plot_cnt +1;
end
figure(71)

%%

q= load('/Users/cynthiasteinhardt/Dropbox/single-neuron-stim-model/vestibular-neuron-models/vest_model_pulsatile/simpler_format/relev_data/reg_irreg_simulations/pr_fr_sim_rep1_I0-400_PR0-360_S38.0936_reg1_05_13_2021_12_16.mat')

%load('/Users/cynthiasteinhardt/Dropbox/single-neuron-stim-model/vestibular-neuron-models/vest_model_pulsatile/simpler_format/relev_data/reg_irreg_simulations/pr_fr_sim_rep1_I0-0_PR0-0_S26.383_reg1_05_13_2021_10_21.mat')

%**load('/Users/cynthiasteinhardt/Dropbox/single-neuron-stim-model/vestibular-neuron-models/vest_model_pulsatile/simpler_format/relev_data/reg_irreg_simulations/pr_fr_sim_I0-400_PR0-360_S31.8392_reg1_05_12_2021_21_16.mat')

%load('/Users/cynthiasteinhardt/Dropbox/single-neuron-stim-model/vestibular-neuron-models/vest_model_pulsatile/simpler_format/relev_data/reg_irreg_simulations/pr_fr_sim_I0-400_PR0-360_S63.5258_reg1_05_13_2021_02_14.mat')%load('/Users/cynthiasteinhardt/Dropbox/single-neuron-stim-model/vestibular-neuron-models/vest_model_pulsatile/simpler_format/relev_data/reg_irreg_simulations/pr_fr_sim_I360-600_PR0-360_S37.7778_reg1_05_10_2021_22_06.mat')

%load('/Users/cynthiasteinhardt/Dropbox/single-neuron-stim-model/vestibular-neuron-models/vest_model_pulsatile/simpler_format/relev_data/reg_irreg_simulations/pr_fr_sim_I386-400_PR0-360_S37.6296_reg1_05_10_2021_22_54.mat')

%load('/Users/cynthiasteinhardt/Dropbox/single-neuron-stim-model/vestibular-neuron-models/vest_model_pulsatile/simpler_format/relev_data/reg_irreg_simulations/pr_fr_sim_rep1_I0-400_PR0-360_S38.0936_reg1_05_13_2021_12_16.mat')
%load('/Users/cynthiasteinhardt/Dropbox/single-neuron-stim-model/vestibular-neuron-models/vest_model_pulsatile/simpler_format/relev_data/reg_irreg_simulations/fr_reps_5_steps_07-May-2021_reg_1_spking_1.mat')

%load('/Users/cynthiasteinhardt/Dropbox/single-neuron-stim-model/vestibular-neuron-models/vest_model_pulsatile/simpler_format/relev_data/reg_irreg_simulations/pr_fr_sim_I0-360_PR0-360_S53.1938_reg1_05_07_2021_05_28.mat')

for n = 1:25
figure(1); subplot(5,11,n); 
%plot(q.pulse_rate,squeeze(mean(q.fr(n,:,:),3)),'k'); hold on;
plot(q.pulse_rate,q.fr(n,:),'k'); hold on;
end

% %% Pulse rate modulation as in https://www.ncbi.nlm.nih.gov/pmc/articles/PMC6948863/#sd
% v ;%velocity waveform
% v_max=  400; %0/sec
% %p_baseline relates to 0;%0degrees/sec
% %Used setting for MVI001 sigmoidal 
% p_min = 0; p_max = 400; p_baseline = 100; C_rate = 2;
% X = atanh(2*((p_baseline - p_min)/(p_max - p_min)) - 1);
% p_t = 0.5*(p_max - p_min) *(1 + tanh(X+C_rate*(v/v_max))) + p_min;
% 
% %Comparable PRM + PAM experiments: https://iopscience.iop.org/article/10.1088/1741-2560/13/4/046023/pdf
% %Preserves amount of delivered current
% %Male BVL1 DFNA9 - PAN - 200 pps 200 uA base line:
% %high modulation:  56 uA+- and 55 pps
% %Modulation frequency 1 Hz
%% Extra section for trying random pulsatile waveforsm
%Cathoding only pulse
%anodic only pulse
%Weirdly shaped pulse (e.g. longer anodic phase than cathodic
expt.num = [];
run_mode = 'override';
%Deciding what outputs to visualize:
output.vis_plot = 1; %If want to see the afferent model APs without experiments
output.vis_plot_num = 6; %plot number when visualizing
output.label_aps = 0; %This is meaningless if don't set the seed, etc. - for check if AP spont or pulse induced
output.all_spk = 0;
output.do_phase_plane_anal = 0;
output.demo_pulse_mod = 0;
inj_cur = [1 0];
pulse_rate = 2; curr_options = -4;
tot_reps =1;
[override] = set_overrides_v2(run_mode,output,{'pulse_rate',pulse_rate },...
    {'curr_options',curr_options},{'mu_IPT',1.5},{'inj_cur',inj_cur},{'is_reg',0},...
    {'do_jitter',0},{'tot_reps',tot_reps},{'epsc_scale',1},{'sim_time',250},{'isDC',0},...
    {'full_seq',1});
disp([ override.gNas override.gKHs override.gKLs override.sim_info.mu_IPT])

change_params.neuron.gNa =  override.gNas;
change_params.neuron.gKL =override.gKLs;
change_params.neuron.gKH =override.gKHs;
            
change_params.Inj_cur = curr_options;
change_params.pulse_rate = pulse_rate;
change_params.full_seq= sim_info.full_seq;
sim_info = override.sim_info;
sim_info.isPlan =1;%give specific sequence

stim_interval_1_length = 150;%us = 1e-3 ms
stim_interval_2_length = 150;%us = 1e-3 ms
I_1 = -7.5; I_2 = -I_1; %order: 2,-2, 3,-3
I_st = zeros(1,sim_info.sim_time*sim_info.dt);
pulse_t_ms = [200:4:224];
pulse_timing = pulse_t_ms*sim_info.dt;%ms num_ps=length(pulse_timing);
slow_return = 1;%1;
inter_phase_interval = 0;%70;
if slow_return %triangular recovery
portion_height = .1;
%stim_interval_1_length*I_1 (area square) = height*length*.5 (triangle);
%height = I_1*portion_height;
stim_interval_2_length = stim_interval_1_length*2*(1/portion_height);

m_return = (portion_height*I_1)/(stim_interval_2_length);
end
for num_ps = 1:length(pulse_timing)
I_st(pulse_timing(num_ps):pulse_timing(num_ps)+stim_interval_1_length-1) =  I_1;%7.5; %uA - value (p 65) 
if slow_return
I_st((inter_phase_interval+pulse_timing(num_ps)+stim_interval_1_length):...
    (inter_phase_interval+pulse_timing(num_ps)+stim_interval_1_length+stim_interval_2_length)) = ...
    portion_height*-I_1+(m_return*([0:stim_interval_2_length]));
else %two square
    I_st(inter_phase_interval+pulse_timing(num_ps)+stim_interval_1_length:pulse_timing(num_ps)+round(stim_interval_1_length+stim_interval_2_length)-1) = I_2;
end
end
%%%Visualizing the pulse shape
% figure(8);
% plot(I_st)
% xlim([199e3 201e3])

sim_info.I_st =I_st;%define the exact pulse sequence
change_params.pulse_timing = pulse_timing;
% For do_CV_plot or pulse_adapt case
for rep_num = 1:tot_reps
    % rng(10) %same EPSCS
    [spiking_info] = run_expt_on_axon_10_10_20_f(sim_info,output,change_params);
end
xlim([195 240])
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FUNCTIONS FOR ABOVE

%hist_mod_IPI_ISI(5,13)
function [] = hist_mod_IPI_ISI(IPI,fig_num)
map = brewermap(3,'Set1');
P_AP1 = normrnd(22,13,[1 1000]);
P_AP2 = P_AP1 + normrnd(22,13,[1 1000]);
P_AP3 = P_AP2+ normrnd(22,13,[1 1000]);
face_alpha = .3;
figure(fig_num); subplot(4,1,1); 
histogram(P_AP1,20,'facecolor',map(1,:),'facealpha',face_alpha,'edgecolor',map(1,:)); hold on;%,'none'); hold on;
histogram(P_AP2,20,'facecolor',map(2,:),'facealpha',face_alpha,'edgecolor',map(2,:));%'none'); 
histogram(P_AP3,20,'facecolor',map(3,:),'facealpha',face_alpha,'edgecolor',map(3,:));%'none') 
title([num2str(IPI) ' ms'])
box off;
set(gca,'fontsize',14)
subplot(4,1,2);
histogram(mod(P_AP1,IPI),20,'facecolor',map(1,:),'facealpha',face_alpha,'edgecolor',map(1,:)); hold on;%,'none'); hold on;
% box off;
% set(gca,'fontsize',14)
% subplot(4,1,3);
histogram(mod(P_AP2,IPI),20,'facecolor',map(2,:),'facealpha',face_alpha,'edgecolor',map(2,:));%'none'); 
% box off;
% set(gca,'fontsize',14)
% subplot(4,1,4);
histogram(mod(P_AP3,IPI),20,'facecolor',map(3,:),'facealpha',face_alpha,'edgecolor',map(3,:));%'none') 
box off;
set(gca,'fontsize',14)

end