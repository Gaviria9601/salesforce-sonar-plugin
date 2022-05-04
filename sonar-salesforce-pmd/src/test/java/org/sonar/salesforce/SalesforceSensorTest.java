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
package org.sonar.salesforce.parser;

import org.junit.Before;
import org.junit.Ignore;
import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.TemporaryFolder;
import org.sonar.api.batch.fs.internal.DefaultFileSystem;
import org.sonar.api.batch.fs.internal.DefaultIndexedFile;
import org.sonar.api.batch.fs.internal.DefaultInputFile;
import org.sonar.api.batch.measure.Metric;
import org.sonar.api.batch.sensor.SensorContext;
import org.sonar.api.batch.sensor.SensorDescriptor;
import org.sonar.api.scan.filesystem.PathResolver;
import org.sonar.salesforce.SalesforcePlugin;
import org.sonar.salesforce.SalesforceSensor;
import org.sonar.salesforce.base.SalesforceConstants;

import java.io.File;
import java.io.IOException;
import java.net.URISyntaxException;
import java.net.URL;
import java.nio.file.Paths;

import static org.fest.assertions.Assertions.assertThat;
import static org.mockito.Matchers.any;
import static org.mockito.Matchers.anyString;
import static org.mockito.Mockito.*;

public class SalesforceSensorTest {
    private DefaultFileSystem fileSystem;
    private PathResolver pathResolver;
    private SalesforceSensor sensor;
    private File baseDir;

    private File sampleReport;

    @Rule
    public TemporaryFolder temp = new TemporaryFolder();

    @Before
    public void init() throws IOException, URISyntaxException {
        baseDir = temp.newFolder();
        fileSystem = new DefaultFileSystem(baseDir);
        this.pathResolver = mock(PathResolver.class);
        this.sensor = new SalesforceSensor(this.fileSystem,this.pathResolver);

        // mock a sample report
        final URL sampleResourceURI = getClass().getClassLoader().getResource("report/pmd-report.xml");
        assert sampleResourceURI != null;
        this.sampleReport = Paths.get(sampleResourceURI.toURI()).toFile();
    }

    @Test
    public void toStringTest() {
        assertThat(this.sensor.toString()).isEqualTo("Salesforce");
    }

    @Test
    public void testDescribe() {
        final SensorDescriptor descriptor = mock(SensorDescriptor.class);
        sensor.describe(descriptor);
        verify(descriptor).name("Salesforce");
    }

    @Test
    public void shouldAnalyseFiles() throws IOException {
        final SensorContext context = mock(SensorContext.class, RETURNS_DEEP_STUBS);
        String fileName = "test_doc.cls";
        ClassLoader classLoader = getClass().getClassLoader();
        File source = new File(classLoader.getResource(fileName).getFile());
        DefaultIndexedFile defaultIndexedFile = new DefaultIndexedFile(fileName, source.toPath(), source.getPath(),SalesforcePlugin.LANGUAGE_KEY);
        DefaultInputFile inputFile = new DefaultInputFile(defaultIndexedFile,null);
        fileSystem.add(inputFile);
        when(context.settings().getString(SalesforceConstants.REPORT_PATH_PROPERTY)).thenReturn("pmd-report.xml");
        when(pathResolver.relativeFile(any(File.class), anyString())).thenReturn(sampleReport);
        sensor.execute(context);

    }

    @Test
    public void shouldAnalyse() throws URISyntaxException {
        final SensorContext context = mock(SensorContext.class, RETURNS_DEEP_STUBS);

        when(context.settings().getString(SalesforceConstants.REPORT_PATH_PROPERTY)).thenReturn("pmd-report.xml");
        when(pathResolver.relativeFile(any(File.class), anyString())).thenReturn(sampleReport);
        sensor.execute(context);
    }

    @Test
    public void shouldSkipIfReportWasNotFound() throws URISyntaxException {
        final SensorContext context = mock(SensorContext.class, RETURNS_DEEP_STUBS);

        when(pathResolver.relativeFile(any(File.class), anyString())).thenReturn(null);
        sensor.execute(context);
        verify(context, never()).newIssue();
    }

    @Test
    @Ignore
    public void shouldAddAnIssueForAViolation() throws URISyntaxException {
        final SensorContext context = mock(SensorContext.class, RETURNS_DEEP_STUBS);

        when(context.settings().getString(SalesforceConstants.REPORT_PATH_PROPERTY)).thenReturn("pmd-report.xml");
        when(pathResolver.relativeFile(any(File.class), anyString())).thenReturn(sampleReport);
        sensor.execute(context);

        verify(context, times(12)).newIssue();
    }

    @Test
    @Ignore
    public void shouldPersistTotalMetrics() throws URISyntaxException {
        final SensorContext context = mock(SensorContext.class, RETURNS_DEEP_STUBS);

        when(context.settings().getString(SalesforceConstants.REPORT_PATH_PROPERTY)).thenReturn("pmd-report.xml");
        when(pathResolver.relativeFile(any(File.class), anyString())).thenReturn(sampleReport);
        sensor.execute(context);

        verify(context.newMeasure(), times(4)).forMetric(any(Metric.class));
    }

    // FIXME
    // @Test
    // public void shouldPersistMetricsOnReport() throws URISyntaxException {
    //     final SensorContext context = mock(SensorContext.class, RETURNS_DEEP_STUBS);

    //     when(context.settings().getString(SalesforceConstants.REPORT_PATH_PROPERTY)).thenReturn("pmd-report.xml");
    //     when(pathResolver.relativeFile(any(File.class), anyString())).thenReturn(sampleReport);
    //     sensor.execute(context);

    //     verify(context.newMeasure(), atLeastOnce()).on(any(InputComponent.class));
    // }
}
