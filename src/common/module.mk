#
# Module makefile for the full client
#
DIR := src/common

COMMON_SRC := $(DIR)/access_pattern.c \
	$(DIR)/barrier.c \
	$(DIR)/datapatterns.c \
	$(DIR)/debug.c \
	$(DIR)/global_clock.c \
	$(DIR)/global_data.c \
	$(DIR)/global_time.c \
	$(DIR)/memory.c \
	$(DIR)/pclk.c \
	$(DIR)/processor.c \
	$(DIR)/ptds.c \
	$(DIR)/timestamp.c