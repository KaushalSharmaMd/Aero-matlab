% Simulating Transducer Field Patterns Example
%
% This example demonstrates the use of k-Wave to compute the field pattern
% generated by a curved single element transducer in two dimensions. It
% builds on the Monopole Point Source In A Homogeneous Propagation Medium
% Example.
%
% author: Bradley Treeby
% date: 10th December 2009
% last update: 24th August 2014
%  
% This function is part of the k-Wave Toolbox (http://www.k-wave.org)
% Copyright (C) 2009-2014 Bradley Treeby and Ben Cox

% This file is part of k-Wave. k-Wave is free software: you can
% redistribute it and/or modify it under the terms of the GNU Lesser
% General Public License as published by the Free Software Foundation,
% either version 3 of the License, or (at your option) any later version.
% 
% k-Wave is distributed in the hope that it will be useful, but WITHOUT ANY
% WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
% FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public License for
% more details. 
% 
% You should have received a copy of the GNU Lesser General Public License
% along with k-Wave. If not, see <http://www.gnu.org/licenses/>. 

clear all;

% =========================================================================
% SIMULATION
% =========================================================================

% create the computational grid
Nx = 216;           % number of grid points in the x (row) direction
Ny = 216;           % number of grid points in the y (column) direction
dx = 50e-3/Nx;    	% grid point spacing in the x direction [m]
dy = dx;            % grid point spacing in the y direction [m]
kgrid = makeGrid(Nx, dx, Ny, dy);

% define the properties of the propagation medium
medium.sound_speed = 1500;  % [m/s]
medium.alpha_power = 1.5;   % [dB/(MHz^y cm)]
medium.alpha_coeff = 0.75;  % [dB/(MHz^y cm)]

% create the time array
[kgrid.t_array, dt] = makeTime(kgrid, medium.sound_speed);

% define a curved transducer element
source.p_mask = makeCircle(Nx, Ny, 61, 61, 60, pi/2);

% define a time varying sinusoidal source
source_freq = 0.25e6;       % [Hz]
source_mag = 0.5;           % [Pa]
source.p = source_mag*sin(2*pi*source_freq*kgrid.t_array);

% filter the source to remove high frequencies not supported by the grid
source.p = filterTimeSeries(kgrid, medium, source.p);

% create a display mask to display the transducer
display_mask = source.p_mask;

% create a sensor mask covering the entire computational domain using the
% opposing corners of a rectangle
sensor.mask = [1, 1, Nx, Ny].';

% set the record mode capture the final wave-field and the statistics at
% each sensor point 
sensor.record = {'p_final', 'p_max', 'p_rms'};

% assign the input options
input_args = {'DisplayMask', display_mask, 'PMLInside', false, 'PlotPML', false};

% run the simulation
sensor_data = kspaceFirstOrder2D(kgrid, medium, source, sensor, input_args{:});

% =========================================================================
% VISUALISATION
% =========================================================================

% add the source mask onto the recorded wave-field
sensor_data.p_final(source.p_mask ~= 0) = 1;
sensor_data.p_max(source.p_mask ~= 0) = 1;
sensor_data.p_rms(source.p_mask ~= 0) = 1;

% plot the final wave-field
figure;
subplot(1, 3, 1), imagesc(kgrid.y_vec*1e3, kgrid.x_vec*1e3, sensor_data.p_final, [-1 1]);
colormap(getColorMap);
ylabel('x-position [mm]');
xlabel('y-position [mm]');
axis image;
title('Final Wave Field');

% plot the maximum recorded pressure
subplot(1, 3, 2), imagesc(kgrid.y_vec*1e3, kgrid.x_vec*1e3, sensor_data.p_max, [-1 1]);
colormap(getColorMap);
ylabel('x-position [mm]');
xlabel('y-position [mm]');
axis image;
title('Maximum Pressure');

% plot the rms recorded pressure
subplot(1, 3, 3), imagesc(kgrid.y_vec*1e3, kgrid.x_vec*1e3, sensor_data.p_rms, [-1 1]);
colormap(getColorMap);
ylabel('x-position [mm]');
xlabel('y-position [mm]');
axis image;
title('RMS Pressure');
scaleFig(2, 1);