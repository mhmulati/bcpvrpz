#Fork of Makefile-with-Lemon-installed. By mhmulati.

#================= GUROBI =====================================================
VERSION := $(shell gurobi_cl --version | cut -c 26,28,30 | head -n 1)
FLAGVERSION := $(shell gurobi_cl --version | cut -c 26,28 | head -n 1)

ifeq ($(shell uname), Darwin)
        $(info )
        $(info *)
        $(info *        Makefile for MAC OS environment)
        $(info *)
	PLATFORM = mac64
	ifneq ($(RELEASE), 11)
                # The next variable must be used to compile *and* link the obj. codes
		CPPSTDLIB = -stdlib=libc++
	else
                $(info )
                $(info *    Gurobi library is not compatible with code)
                $(info *    generated by clang c++11 in MAC OS.)
                $(info *    Please, verify if it is compatible now.)
                $(info *)
                $(info *    >>>>> Aborted <<<<<)
                $(info *)
                $(error *)
		CPPSTDLIB = -stdlib=libc++ -std=c++11
	endif
	CC      = g++
	#CC_ARGS    = -Wall -m64 -O3 -Wall $(CPPSTDLIB)  -Wno-c++11-extensions
	CC_ARGS    =  -m64  -O2 -Wall -std=c++11 -D_GLIBCXX_USE_CXX11_ABI=0 
	RELEASE := $(shell uname -r | cut -f 1 -d .)
	CC_LIB   = -lm -lpthread $(CPPSTDLIB)
	GUROBI_DIR = /Library/gurobi$(VERSION)/$(PLATFORM)
else
        $(info )
        $(info *)
        $(info *        Makefile for LINUX environment)
        $(info *)
	PLATFORM = linux64
	CC      = g++
	#CC_ARGS    = -m64 -O2 -Wall -std=c++11
	CC_ARGS    = -m64 -O2 -Wall -std=c++11 -D_GLIBCXX_USE_CXX11_ABI=0 
	RELEASE := $(shell uname -r | cut -f 1 -d .)
	CC_LIB   = -lm -lpthread
	GUROBI_DIR = /home/matheus/gurobi$(VERSION)/$(PLATFORM)
endif
GUROBI_INC = -I$(GUROBI_DIR)/include/
GUROBI_LIB = -L$(GUROBI_DIR)/lib/  -lgurobi_c++ -lgurobi$(FLAGVERSION)  $(CPPSTDLIB)
#================= LEMON =====================================================

LEMONDIR  = /home/matheus/lemon
LEMONINCDIR  = -I$(LEMONDIR)/include
LEMONLIBDIR  = -L$(LEMONDIR)/lib

#================= CVRPSEP =====================================================
CVRPSEPDIR  = CVRPSEP
CVRPSEPINCDIR  = -I$(CVRPSEPDIR)/include
CVRPSEPLIBDIR  = $(CVRPSEPDIR)/lib/libCVRPSEP.a

#---------------------------------------------
# define includes and libraries

INC = $(GUROBI_INC) $(LEMONINCDIR) $(CVRPSEPINCDIR)
LIB = $(CC_LIB) $(GUROBI_LIB)  $(LEMONLIBDIR) -lemon 


# g++ -m64 -g -o exe readgraph.cpp viewgraph.cpp adjacencymatrix.cpp ex_fractional_packing.o -I/Library/gurobi600/mac64/include/ -L/Library/gurobi600/mac64/lib/ -lgurobi_c++ -lgurobi60 -stdlib=libstdc++ -lpthread -lm
# g++ -m64 -g -c adjacencymatrix.cpp -o adjacencymatrix.o -I/Library/gurobi600/mac64/include/  -stdlib=libstdc++ 

MYLIBSOURCES = mygraphlib.cpp geompack.cpp myutils.cpp cvrpalgs.cpp
MYOBJLIB = $(MYLIBSOURCES:.cpp=.o)

EX =  cvrp.cpp
OBJEX = $(EX:.cpp=.o)

EXE = $(EX:.cpp=.e)

all: mylib.a $(OBJEX) $(EXE)

mylib.a: $(MYOBJLIB) $(MYLIBSOURCES)
	#libtool -o $@ $(MYOBJLIB)
	ar cru $@ $(MYOBJLIB)
	#ar cr $@ $(MYOBJLIB)  # by mhmulati, https://bugzilla.redhat.com/show_bug.cgi?id=1155273

%.o: %.cpp 
	$(CC) $(CC_ARGS) -c $^ $(INC) -o $@  

%.e: %.o  mylib.a
	$(CC) $(CC_ARGS) $^ -o $@ $(CVRPSEPLIBDIR) $(LIB) 

.cpp.o:
	$(CC) -c $(CARGS) $< -o $@

clean:
	rm -f $(OBJ) $(MYOBJLIB) $(EXE) $(OBJEX) *~ core mylib.a
