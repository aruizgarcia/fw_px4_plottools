function [params] = setupParams()
% topics mapping for the latest master

params = struct;

% actuator trims
params.trim_roll = ...
    struct('param_name', 'trim_roll', 'logged', false);
params.trim_pitch = ...
    struct('param_name', 'trim_pitch', 'logged', false);
params.trim_yaw = ...
    struct('param_name', 'trim_yaw', 'logged', false);

% airflow vane calibration parameters
params.cal_aoa_off = ...
    struct('param_name', 'cal_aoa_off', 'logged', false);
params.cal_slip_off = ...
    struct('param_name', 'cal_slip_off', 'logged', false);
params.cal_hall_min = ...
    struct('param_name', 'cal_hall_min', 'logged', false);
params.cal_hall_max = ...
    struct('param_name', 'cal_hall_max', 'logged', false);
params.cal_hall_rev = ...
    struct('param_name', 'cal_hall_rev', 'logged', false);
params.cal_hall_p0 = ...
    struct('param_name', 'cal_hall_p0', 'logged', false);
params.cal_hall_p1 = ...
    struct('param_name', 'cal_hall_p1', 'logged', false);
params.cal_hall_p2 = ...
    struct('param_name', 'cal_hall_p2', 'logged', false);
params.cal_hall_p3 = ...
    struct('param_name', 'cal_hall_p3', 'logged', false);
params.cal_hall_01_min = ...
    struct('param_name', 'cal_hall_01_min', 'logged', false);
params.cal_hall_01_max = ...
    struct('param_name', 'cal_hall_01_max', 'logged', false);
params.cal_hall_01_rev = ...
    struct('param_name', 'cal_hall_01_rev', 'logged', false);
params.cal_hall_01_p0 = ...
    struct('param_name', 'cal_hall_01_p0', 'logged', false);
params.cal_hall_01_p1 = ...
    struct('param_name', 'cal_hall_01_p1', 'logged', false);
params.cal_hall_01_p2 = ...
    struct('param_name', 'cal_hall_01_p2', 'logged', false);
params.cal_hall_01_p3 = ...
    struct('param_name', 'cal_hall_01_p3', 'logged', false);

% servo rail PWM config
for i=1:8
    str_ = ['pwm_main_min',int2str(i)];
    params.(str_) = struct('param_name', str_, 'logged', false);
end
for i=1:8
    str_ = ['pwm_main_max',int2str(i)];
    params.(str_) = struct('param_name', str_, 'logged', false);
end
for i=1:8
    str_ = ['pwm_main_rev',int2str(i)];
    params.(str_) = struct('param_name', str_, 'logged', false);
end
for i=1:8
    str_ = ['pwm_main_trim',int2str(i)];
    params.(str_) = struct('param_name', str_, 'logged', false);
end
clearvars str_;

% sys id
params.sid_ail_n_scl = ...
    struct('param_name', 'sid_ail_n_scl', 'logged', false);
params.sid_ail_p_scl = ...
    struct('param_name', 'sid_ail_p_scl', 'logged', false);
params.sid_ele_scl = ...
    struct('param_name', 'sid_ele_scl', 'logged', false);
params.sid_flp_n_scl = ...
    struct('param_name', 'sid_flp_n_scl', 'logged', false);
params.sid_flp_p_scl = ...
    struct('param_name', 'sid_flp_p_scl', 'logged', false);
params.sid_fs = ...
    struct('param_name', 'sid_fs', 'logged', false);
params.sid_f_end = ...
    struct('param_name', 'sid_f_end', 'logged', false);
params.sid_f_st = ...
    struct('param_name', 'sid_f_st', 'logged', false);
params.sid_man = ...
    struct('param_name', 'sid_man', 'logged', false);
params.sid_nom1 = ...
    struct('param_name', 'sid_nom1', 'logged', false);
params.sid_nom2 = ...
    struct('param_name', 'sid_nom2', 'logged', false);
params.sid_nom3 = ...
    struct('param_name', 'sid_nom3', 'logged', false);
params.sid_rep = ...
    struct('param_name', 'sid_rep', 'logged', false);
params.sid_sel = ...
    struct('param_name', 'sid_sel', 'logged', false);
params.sid_settle = ...
    struct('param_name', 'sid_settle', 'logged', false);
params.sid_step = ...
    struct('param_name', 'sid_step', 'logged', false);
params.sid_trise = ...
    struct('param_name', 'sid_trise', 'logged', false);
params.sid_t_exc = ...
    struct('param_name', 'sid_t_exc', 'logged', false);
params.sid_xtra_pitch = ...
    struct('param_name', 'sid_xtra_pitch', 'logged', false);
params.sid_xtra_roll = ...
    struct('param_name', 'sid_xtra_roll', 'logged', false);

% pitot calibration parameters
params.cal_air_cmodel = ...
    struct('param_name', 'cal_air_cmodel', 'logged', false);
params.cal_air_tubelen = ...
    struct('param_name', 'cal_air_tubelen', 'logged', false);
params.cal_air_tubed_mm = ...
    struct('param_name', 'cal_air_tubed_mm', 'logged', false);