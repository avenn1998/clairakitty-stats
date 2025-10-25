#Setting up
import AO3
import datetime
import pandas as pd
import pathlib

#Initializing user
username = "clairakitty"
user = AO3.User(username)

#Reading in existing CSV
path = pathlib.Path(username + "_ao3_work_stats.csv")
if path.exists():
    df = pd.read_csv(path)

works = user.get_works()

work_stats = pd.DataFrame(columns = ["time", "work_title", "kudos", "hits", "bookmarks", "comments", "chapters", "words"])
start = datetime.datetime.today()
for work in works:
    row_dict = {'time': start,
                'work_title': work.title,
                'kudos': work.kudos,
                'hits': work.hits,
                'bookmarks': work.bookmarks,
                'comments': work.comments,
                'chapters': work.nchapters,
                'words': work.words}

    work_stats = pd.concat([work_stats, pd.DataFrame([row_dict])], ignore_index = True)

work_stats_full = pd.concat([df, work_stats], ignore_index = True)

work_stats_full.to_csv(username + "_ao3_work_stats.csv", encoding='utf-8', index=False)
