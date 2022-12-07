#include <iostream>
#include <fstream>
#include <string>
#include <iomanip>
#include <bitset>
#include <map>

void write_in_little_endian(std::fstream& fs, uint32_t number){
                fs << (unsigned char)(number & 255) <<
                       (unsigned char)((number >> 8 ) & 255) <<
                       (unsigned char)((number >> 16) & 255) <<
                       (unsigned char)((number >> 24) & 255);
}

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

	input_file >> state_count;
	write_in_little_endian(output_file, state_count);

	int state_max_length = 10;
	std::map<std::string, uint32_t> states_order;

	for (uint32_t i = 0; i != state_count; ++i){
		std::string state;
		input_file >> state;
		output_file << std::setw(10) << std::setfill('\0') << state;
		states_order[state] = i;
	}

	std::string initial_state, terminal_state;
	input_file >> initial_state >> terminal_state;

	write_in_little_endian(output_file, states_order[initial_state]);
	write_in_little_endian(output_file, states_order[terminal_state]);

	unsigned int transitions_count;

	input_file >> transitions_count;
	write_in_little_endian(output_file, transitions_count);

	unsigned int transitions_table_size = state_count * 128 * 4;
	char transitions[transitions_table_size] = { };

	for (int i = 0; i != transitions_count; ++i){
		std::string from_state, to_state;
		unsigned char from_ch, to_ch, move;
		input_file >> from_state >> from_ch >> to_state >> to_state >> to_ch >> move;
		if (move == 'L') move = 1;
		if (move == 'S') move = 2;
		if (move == 'R') move = 3;
		int transition_start_pos = states_order[from_state] * 512 + from_ch * 4;
		transitions[transition_start_pos] = states_order[to_state];
	        transitions[transition_start_pos + 1] = to_ch;
		transitions[transition_start_pos + 2] = move;
	}
	for (int i = 0; i != transitions_table_size; ++i){
		output_file << transitions[i];
	}

	std::string tape;

	input_file >> tape;
	write_in_little_endian(output_file, tape.size());
	output_file << tape;

	return 0;
}
