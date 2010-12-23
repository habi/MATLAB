clc;clear all;
pixels = 14000;
bit = 8;
images = 2048;

imagesize_px = pixels ^ 2;

imagesize_byte = imagesize_px * bit / 8

imagesize_mb = imagesize_byte / 2^20

size_dataset = imagesize_mb * images / 1000