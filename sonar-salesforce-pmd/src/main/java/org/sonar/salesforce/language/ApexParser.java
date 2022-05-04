/*
 * Salesforce Plugin for SonarQube
 * Copyright (C) 2018-2017 Salesforce.org
 * esteele@salesforce.com
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program; if not, write to the Free Software Foundation,
 * Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */
package org.sonar.salesforce.language;

import org.apache.commons.lang3.StringUtils;

import java.util.List;

public class ApexParser {

    private int lineCount = 0;
    private int emptyLineCount = 0;
    private int commentLineCount = 0;


    public ApexParser() { }

    public int getLineCount() { return lineCount; }
    public int getEmptyLineCount() { return emptyLineCount; }
    public int getCommentLineCount() { return commentLineCount; }


    public void parse(List<String> lines) {
        this.parseLines(lines);
    }

    private void parseLines(List<String> lines) {

        lineCount = lines.size();
        for (int i = 0; i < lineCount; i++) {
            String line = lines.get(i);
            if (StringUtils.isBlank(line)) {
                emptyLineCount++;
            }

            if (line.matches("(\\/*.*[a-zA-Z])") || line.matches("(\\/*.*\\*)")) {
                lineCount--;
            }
            if (line.matches("(.*\\s\\/\\/)([^\\n\\r]+)")) {
                commentLineCount++;
            }
        }
    }

}
