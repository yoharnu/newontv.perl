import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.Scanner;
import java.net.URL;
import java.util.regex.*;

public class NewOnTV {

	NewOnTV(String showsFile) throws IOException {
		//System.out.print("Language (two letter abbreviation): ");
		//String language = System.console().readLine();
		ArrayList<String> shows = parseShows(showsFile);
		//ArrayList<Show> newShows = checkNew(shows);
		ArrayList<String> newShows = checkNew(shows);
		shows.clear();
		System.out.println(newShows.toString());
	}

	protected ArrayList<String> parseShows(String showsFile)
			throws FileNotFoundException {
		ArrayList<String> shows = new ArrayList<String>();
		Scanner s = new Scanner(new File(showsFile));
		while (s.hasNext()) {
			shows.add(s.nextLine());
		}
		s.close();
		return shows;
	}

	protected ArrayList<String> checkNew(ArrayList<String> shows)
			throws IOException {
		URL tvguide = new URL("http://www.tvguide.com/new-tonight/80001");
		Scanner s = new Scanner(new BufferedReader(new InputStreamReader(
				tvguide.openStream())));
		Pattern pattern = Pattern.compile("<h6 id=\"(.*)\">.*</h6>");
		System.out.println(pattern.pattern());
		ArrayList<String> rtn = new ArrayList<String>();
		while (s.hasNext()) {
			String t = s.nextLine();
			Matcher m = pattern.matcher(t);
			//System.out.println(t);
			if (Pattern.matches("<h6 id=\".*\">.*</h6>", t)) {
				for(int i = 0; i < 11; i++)
					s.nextLine();
				pattern = Pattern.compile("<a href=\".*\">.*</a>");
				System.out.println(pattern.pattern());
				t = s.nextLine();
				m = pattern.matcher(t);
				for (int i = 0; i < shows.size(); i++) {
					if (m.group().equals(shows.get(i))) {
						String temp = makeReplacements(shows.get(i));
						System.out.println(temp);
						rtn.add(temp);
					}
				}
			}
		}
		s.close();
		return rtn;
	}

	protected String makeReplacements(String before) {
		String after = before;
		after.replaceAll("\\s+", " ");
		after.replaceAll("Doctor Who", "Doctor Who (2005)");
		after.replaceAll("Prime Suspect", "Prime Suspect (US)");
		after.replaceAll("Last Man Standing", "Last Man Standing (2011)");
		after.replaceAll("Being Human", "Being Human (US)");
		after.replaceAll("Once Upon a Time", "Once Upon a Time (2011)");
		after.replaceAll("Castle", "Castle (2009)");
		after.replaceAll("Touch", "Touch (2012)");
		after.replaceAll("Smash", "Smash (2012)");
		after.replaceAll("CSI:\\s*Crime Scene Investigation", "CSI");

		return after;
	}

	public static void main(String[] args) throws IOException {
		new NewOnTV(args[0]);
	}

}
