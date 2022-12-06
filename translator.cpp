#include <iostream>
#include <fstream>
#include <string>
#include <iomanip>
#include <bitset>

int main(int argc, char* argv[]){
	if (argc < 3){
		std::cout << "Not enough arguments\n";
		return 1;
	}
	std::fstream input_file;
	std::fstream output_file;
	input_file.open(argv[1], std::ios::in);
	if (!input_file){
		std::cout << "Can not open " << argv[1] << '\n';
		return 1;
	}
	output_file.open(argv[2], std::ios::out);
	if (!output_file){
		std::cout << "Can not open" << argv[2] << '\n';
		input_file.close();
		return 1;
	}
	uint32_t state_count;
	int state_max_length = 10;
	input_file >> state_count;
	output_file << (state_count & 255) <<
                       ((state_count >> 8 ) & 255) <<
                       ((state_count >> 16) & 255) <<
                       ((state_count >> 24) & 255);
	for (int i = 0; i != state_count; ++i){
		std::string state;
		input_file >> state;
		output_file << std::setw(10) << std::setfill('\0') << state;
	}
	return 0;
}
