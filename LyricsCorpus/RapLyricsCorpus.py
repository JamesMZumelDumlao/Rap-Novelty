def get_ArtistsMaxSongNumbers(list_of_artists, max_song_num):
    '''
    ArtistsMaxSongNumbers is a dictionary that has the names of artists to search and the max number of 
    songs to retrieve for each artist. Suggested to use function to create the dictionary where all artists have same 
    max_song_number and thereafter alter for any differences sought for specific artists
    '''
    max_song_number_list = [max_song_num]*len(list_of_artists)
    return dict(zip(list_of_artists, max_song_number_list))

class hiphop():
    ''' Class that interfaces with LyricsGenius and ensures outputs for multiple Artists saved in a single file
    called compendium.json
    '''
    import lyricsgenius as genius
    import os
    
    def __init__(self, client_access_token, ArtistsMaxSongNumberz):
        import lyricsgenius as genius
        import os
        self.client_access_token = client_access_token
        self.api = genius.Genius(self.client_access_token,
                 response_format='plain', timeout=5, sleep_time=0.5,
                 verbose=True, remove_section_headers=False,
                 skip_non_songs=True, excluded_terms=[],
                 replace_default_terms=False)
        assert isinstance(ArtistsMaxSongNumberz, dict), "Only dictionaries with artist-max_song_number pairs accepted"
        self.ArtistsMaxSongNumbers = ArtistsMaxSongNumberz
        self.compendium = {}
        self.dict_for_pandas ={}
        
    
    def add_artists_and_songs(self):
        '''
        Adds artists and their song (or where artists already exist their additional songs) to the compendium of artist information and songs
        '''
        import os
        import json
        
        skip, count = False, 0
        for talent in self.ArtistsMaxSongNumbers.keys():
            if (talent in self.compendium.keys()) and (len(self.compendium[talent]['songs']) == self.ArtistsMaxSongNumbers[talent]):
                print("{} of {}'s songs are already captured in compendium as required. No need to re-search. Leave as is ".format(self.ArtistsMaxSongNumbers[talent], talent))
                count+= 1
                if count == len(self.ArtistsMaxSongNumbers.keys()):
                    skip = True
                continue
            artist = self.api.search_artist(talent, max_songs=self.ArtistsMaxSongNumbers[talent])
            if talent != artist.name:
                print('changing search parameter {} to artist name as found {}'.format(talent, artist.name))
            artist._body['songs'] = [song._body for song in artist.songs]
            self.compendium[artist.name] = artist._body
        
        if skip:
            print('Songs of all the specified artists are already captured in compendium. No update or addition required')
            return None
        else:
            filename = 'compendium.json'
            if input("{} ready to save. Save to file?\n(y/n): ".format(filename)).lower() == 'n':
                return self.compendium
            elif os.path.isfile(filename) and input("file {} already exists. Overwrite?\n(y/n): ".format(filename)).lower() == 'n':
                print('aborting overwrite and returning compendium as dictionary')
                return self.compendium
            else:
                with open(filename, "w") as ff:
                    json.dump(self.compendium, ff, indent=1)
                return self.compendium
    
    
    def resume_after_disconnection(self):
        '''
        to resume song search and addition following an api call disconnected (with Timeout error) without having 
        to re-search for artists and songs previously completed before the api call drop / termination
        '''
        self.add_artists_and_songs()
    
    
    def output_result(self, filepath=None):
        '''
        Output a dataframe with the required parameters from the dictionary returned by add_artists_and_songs() method 
        or gotten the file compendium.json saved by add_artists_and_songs() method
        
        It also converts the compendium into a dicitionary of LyricsGenius Artist objects and Song objects
        such that the LyricsGenius methods can be used on any of these objects to simplify manipulation if required. 
        A get_compendium method is later on provided to enable this compendium attribute to be retrieved on demand
        '''
        import os
        import json
        import pandas as pd
        
        if filepath:
            if os.path.isfile(filepath):
                with open(filepath, 'r') as fd:
                    self.compendium = json.load(fd)
            else:
                print('{}is not a valid file path. Please provide another filepath'.format(filepath))
                return None
        
        for talent in self.compendium.keys():
            self.compendium[talent] = genius.artist.Artist({'artist': self.compendium[talent]})
            for work in self.compendium[talent]._body['songs']:
                lyrics = work.pop('lyrics')
                track = genius.song.Song(work, lyrics)
                self.compendium[talent].add_song(track)
            
        self.dict_for_pandas['Artist_name'] = [self.compendium[talent].name for talent in self.compendium.keys() for work in self.compendium[talent].songs]
        self.dict_for_pandas['Album_name'] = [work.album for talent in self.compendium.keys() for work in self.compendium[talent].songs]
        self.dict_for_pandas['Album_date'] = [work.year for talent in self.compendium.keys() for work in self.compendium[talent].songs]
        self.dict_for_pandas['Song_name'] = [work.title for talent in self.compendium.keys() for work in self.compendium[talent].songs]
        self.dict_for_pandas['Song_lyrics'] = [work.lyrics for talent in self.compendium.keys() for work in self.compendium[talent].songs]
            
        return pd.DataFrame.from_dict(self.dict_for_pandas)

# # #

'''This block allows us to use a list to create a dataframe of all their songs on Genius, using my access token'''

client_access_token = "F4arpDcdvIIymXRrlFhR0qIHq_luNUiNRMyjqiJyPeZrqE4DI6eR6kJ0MO01xE99" 

import pandas as pd
censusxl = pd.read_excel('CleanedRapperCensus.xlsx')
RapperCensus = censusxl['title'].tolist() # This brings in the entire census as a list of names to be fed into the scraper (n=2097)
lst = RapperCensus

argument = get_ArtistsMaxSongNumbers(lst, 1)

corpus = hiphop(client_access_token, argument)
corpus.add_artists_and_songs()


import lyricsgenius as genius
corpus.output_result('compendium.json')
