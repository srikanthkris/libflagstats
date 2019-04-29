###################################################################
# Copyright (c) 2019
# Author(s): Marcus D. R. Klarqvist
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
###################################################################

OPTFLAGS  := -O3 -march=native
CFLAGS     = -std=c99 $(OPTFLAGS) $(DEBUG_FLAGS)
CPPFLAGS   = -std=c++0x $(OPTFLAGS) $(DEBUG_FLAGS)
CPP_SOURCE = lz4_import.cpp utility.cpp
C_SOURCE   = 
OBJECTS    = $(CPP_SOURCE:.cpp=.o) $(C_SOURCE:.c=.o)

POSPOPCNT_PATH  := positional-popcount
LZ4_PATH :=
ZSTD_PATH :=
INCLUDE_PATHS :=
LIBRARY_PATHS :=
ifneq ($(LZ4_PATH),)
	INCLUDE_PATHS += -I$(LZ4_PATH)/include
	LIBRARY_PATHS += -L$(LZ4_PATH)/lib
endif
ifneq ($(ZSTD_PATH),)
	INCLUDE_PATHS += -I$(ZSTD_PATH)/include
	LIBRARY_PATHS += -L$(ZSTD_PATH)/lib
endif

# dedup
INCLUDE_PATHS := $(sort $(INCLUDE_PATHS))
LIBRARY_PATHS := $(sort $(LIBRARY_PATHS))

# Default target
all: flagstats utility

# Generic rules
pospopcnt.o: $(POSPOPCNT_PATH)/pospopcnt.c
	$(CC) $(CFLAGS) -c -o $@ $<

utility.o: utility.cpp
	$(CXX) $(CPPFLAGS) -c -o $@ $<

lz4_import.o: lz4_import.cpp $(POSPOPCNT_PATH)/pospopcnt.c
	$(CXX) $(CPPFLAGS) -I$(POSPOPCNT_PATH) $(INCLUDE_PATHS) -c -o $@ $<

flagstats: lz4_import.o pospopcnt.o
	$(CXX) $(CPPFLAGS) lz4_import.o pospopcnt.o -I$(POSPOPCNT_PATH) $(INCLUDE_PATHS) $(LIBRARY_PATHS) -o flagstats -llz4 -lzstd

utility: utility.o
	$(CXX) $(CPPFLAGS) utility.o -o utility

clean:
	rm -f $(OBJECTS)
	rm -f flagstats

.PHONY: all clean
